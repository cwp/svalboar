//! The bigram metric [`StdMovementPattern`] puts cost on each bigram that is mapped to
//! (almost) neighboring fingers on traditional keyboards. Which finger combinations come
//! with which costs is configurable.

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
pub struct StdMovementPattern {
    finger_switch_factor: HandFingerMap<HandFingerMap<f64>>,
    finger_lengths: HandFingerMap<f64>,
    short_down_to_long_or_long_up_to_short_factor: f64,
    same_row_offset: f64,
    unbalancing_factor: f64,
    lateral_stretch_factor: f64,
}

impl StdMovementPattern {
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

impl BigramMetric for StdMovementPattern {
    fn name(&self) -> &str {
        "Standard Movement Pattern"
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

        // Skip thumbs, different hands, or same finger
        if f1 == Finger::Thumb || f2 == Finger::Thumb || h1 != h2 || f1 == f2 {
            return Some(0.0);
        }

        let pos1 = k1.key.matrix_position;
        let pos2 = k2.key.matrix_position;

        let upwards: bool = pos2.1 < pos1.1;
        let downwards: bool = pos2.1 > pos1.1;

        let finger_length_diff =
            self.finger_lengths.get(&h1, &f1) - self.finger_lengths.get(&h2, &f2);
        let first_is_longer = finger_length_diff > 0.0;
        let first_is_shorter = finger_length_diff < 0.0;

        let _num_rows = pos1.1.abs_diff(pos2.1) as f64;

        let finger_switch_factor = *self.finger_switch_factor.get(&h1, &f1).get(&h2, &f2);

        // Calculate unbalancing factor
        let mut unbalancing_factor = k1.key.unbalancing.0.abs() + k1.key.unbalancing.1.abs();
        if unbalancing_factor == 0.0 {
            unbalancing_factor = 1.0;
        }

        // Calculate lateral stretch factor
        let lateral_stretch_factor = 1.0
            + (f1.distance(&f2))
                .abs_diff(k1.key.matrix_position.0.abs_diff(k2.key.matrix_position.0))
                as f64
                * self.lateral_stretch_factor;

        // Traditional keyboard movement pattern calculation
        let mut cost = finger_switch_factor;

        // Apply modifiers for different movement patterns
        if (upwards && first_is_shorter) || (downwards && first_is_longer) {
            cost *= self.short_down_to_long_or_long_up_to_short_factor;
        }

        // Same row adjustment
        if pos1.1 == pos2.1 {
            cost += self.same_row_offset;
        }

        // Apply lateral stretch and unbalancing factors
        cost *= lateral_stretch_factor;
        cost *= self.unbalancing_factor.powf(unbalancing_factor);

        Some(weight * cost)
    }
}
