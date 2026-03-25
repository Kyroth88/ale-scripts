DELETE FROM spell_dbc WHERE Id = 90001;

INSERT INTO spell_dbc (
    Id,
    Attributes,
    AttributesEx,
    CastingTimeIndex,
    DurationIndex,
    RangeIndex,
    Effect_1,
    EffectBasePoints_1,
    EffectAura_1,
    EffectMiscValue_1,
    ImplicitTargetA_1,
    Name_Lang_enUS,
    Name_Lang_Mask
) VALUES (
    90001,
    0,          -- Attributes
    0,          -- AttributesEx
    1,          -- Instant cast
    21,         -- Infinite duration
    1,          -- Self range
    6,          -- APPLY_AURA
    -10,        -- -10% damage per stack
    79,         -- SPELL_AURA_MOD_DAMAGE_PERCENT_DONE
    127,        -- All damage schools
    1,          -- SELF
    'Raid Damage Reduction Aura',
    0
);
