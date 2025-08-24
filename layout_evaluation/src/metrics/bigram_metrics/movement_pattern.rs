//! The bigram metric [`MovementPattern`] puts cost on each bigram that is mapped to
//! (almost) neighboring fingers. Which finger combinations come with which costs is
//! configurable.

use crate::sval::SvalKeyDirection;

use super::BigramMetric;

use ahash::AHashMap;
use keyboard_layout::{
    key::{Finger, Hand, HandFingerMap},
    layout::{LayerKey, Layout},
};

use serde::Deserialize;

#[derive(Copy, Clone, Deserialize, Debug)]
pub struct FingerSwitchCost {
    pub from: Finger,
    pub to: Finger,
    pub cost: f64,
}

#[derive(Clone, Deserialize, Debug)]
pub struct Parameters {
    /// Cost associated with bigrams from a finger to another one
    finger_switch_factor: Vec<FingerSwitchCost>,
    finger_lengths: AHashMap<Hand, AHashMap<Finger, f64>>,
    short_down_to_long_or_long_up_to_short_factor: f64,
    same_row_offset: f64,
    unbalancing_factor: f64,
    lateral_stretch_factor: f64,
}

#[derive(Clone, Debug)]
pub struct MovementPattern {
    finger_switch_factor: HandFingerMap<HandFingerMap<f64>>,
    finger_lengths: HandFingerMap<f64>,
    short_down_to_long_or_long_up_to_short_factor: f64,
    same_row_offset: f64,
    unbalancing_factor: f64,
    lateral_stretch_factor: f64,
}

impl MovementPattern {
    pub fn new(params: &Parameters) -> Self {
        let mut finger_switch_factor =
            HandFingerMap::with_default(HandFingerMap::with_default(0.0));
        for hand in [Hand::Left, Hand::Right] {
            params.finger_switch_factor.iter().for_each(|fsc| {
                let m = finger_switch_factor.get_mut(&hand, &fsc.from);
                m.set(&hand, &fsc.to, fsc.cost);
            });
        }
        let finger_lengths = HandFingerMap::with_hashmap(&params.finger_lengths, 1.0);

        Self {
            finger_switch_factor,
            finger_lengths,
            short_down_to_long_or_long_up_to_short_factor: params
                .short_down_to_long_or_long_up_to_short_factor,
            same_row_offset: params.same_row_offset,
            unbalancing_factor: params.unbalancing_factor,
            lateral_stretch_factor: params.lateral_stretch_factor,
        }
    }
}

impl BigramMetric for MovementPattern {
    fn name(&self) -> &str {
        "Movement Pattern"
    }

    #[inline(always)]
    fn individual_cost(
        &self,
        k1: &LayerKey,
        k2: &LayerKey,
        weight: f64,
        _total_weight: f64,
        _layout: &Layout,
    ) -> Option<f64> {
        let f1 = k1.key.finger;
        let f2 = k2.key.finger;
        let h1 = k1.key.hand;
        let h2 = k2.key.hand;

        if f1 == Finger::Thumb || f2 == Finger::Thumb || h1 != h2 || f1 == f2 {
            return Some(0.0);
        }

        // let distance = (f1 as i8) - (f2 as i8);
        // if distance == 1 {
        //     return Some(0.0);
        // }

        let pos1 = k1.key.matrix_position;
        let pos2 = k2.key.matrix_position;

        let _upwards: bool = pos2.1 < pos1.1;
        let _downwards: bool = pos2.1 > pos1.1;

        let finger_length_diff =
            self.finger_lengths.get(&h1, &f1) - self.finger_lengths.get(&h2, &f2);
        let _first_is_longer = finger_length_diff > 0.0;
        let _first_is_shorter = finger_length_diff < 0.0;

        let _num_rows = pos1.1.abs_diff(pos2.1) as f64;

        let finger_switch_factor = self.finger_switch_factor.get(&h1, &f1).get(&h2, &f2);

        let mut unbalancing_factor = k1.key.unbalancing.0.abs() + k1.key.unbalancing.1.abs();
        if unbalancing_factor == 0.0 {
            unbalancing_factor = 1.0;
        }

        let _lateral_stretch_factor = 1.0
            + (f1.distance(&f2))
                .abs_diff(k1.key.matrix_position.0.abs_diff(k2.key.matrix_position.0))
                as f64
                * self.lateral_stretch_factor;
        let center_keys = [
            (2, 2),
            (5, 2),
            (8, 2),
            (11, 2),
            (14, 2),
            (17, 2),
            (20, 2),
            (23, 2),
        ];
        let closest_center_1 = center_keys
            .iter()
            .min_by_key(|(x, y)| pos1.0.abs_diff(*x) + pos1.1.abs_diff(*y))
            .unwrap();
        let sval_key_1 = SvalKeyDirection::from_key(&k1.key, closest_center_1);
        if !(sval_key_1 == SvalKeyDirection::East || sval_key_1 == SvalKeyDirection::West) {
            return Some(0.0);
        }

        let cost = finger_switch_factor;

        Some(weight * cost * unbalancing_factor)
    }
}
