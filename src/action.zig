// Each action that can be taken in the game is represented by a number.
// This explicitness lends itself well if this code were to be utilized to write bots
// or potentially deep learning algorithms

const std = @import("std");

const Card = @import("card/card.zig").Card;
const Suit = @import("card/suit.zig").Suit;
const Rank = @import("card/rank.zig").Rank;

pub const Action = enum(u6) {
    const total_actions = 59; // do not change

    // Play actions
    PlayS9, PlayST, PlaySJ, PlaySQ, PlaySK, PlaySA,
    PlayH9, PlayHT, PlayHJ, PlayHQ, PlayHK, PlayHA,
    PlayD9, PlayDT, PlayDJ, PlayDQ, PlayDK, PlayDA,
    PlayC9, PlayCT, PlayCJ, PlayCQ, PlayCK, PlayCA,

    // Discard actions
    DiscardS9, DiscardST, DiscardSJ, DiscardSQ, DiscardSK, DiscardSA,
    DiscardH9, DiscardHT, DiscardHJ, DiscardHQ, DiscardHK, DiscardHA,
    DiscardD9, DiscardDT, DiscardDJ, DiscardDQ, DiscardDK, DiscardDA,
    DiscardC9, DiscardCT, DiscardCJ, DiscardCQ, DiscardCK, DiscardCA,

    // although not necessary, this order matches that of `Suit.Range()`
    CallSpades,
    CallHearts,
    CallDiamonds,
    CallClubs,

    // Go Alone
    CallSpadesAlone,
    CallHeartsAlone,
    CallDiamondsAlone,
    CallClubsAlone,

    // Whether to call or pass on the flipped card
    Pick,
    PickAlone,
    Pass,

    pub const ActionError = error{
        IntOutOfRange,
        StrNotConvertable,
        NotConvertableToCard,
    };

    pub fn ToInt(self: Action) u6 {
        return @intFromEnum(self);
    }

    pub fn FromInt(integer: u6) ActionError!Action {
        if (integer >= total_actions) return ActionError.IntOutOfRange;
        return @enumFromInt(integer);
    }

    pub fn FromStr(str: []const u8) ActionError!Action {
        if (std.meta.stringToEnum(Action, str)) |dude| {
            return dude;
        }
        return ActionError.StrNotConvertable;
    }

    pub fn FromCard(card: Card, to_play: bool) Action {
        const suit_num: u6 = @as(u6, @intFromEnum(card.suit));
        const rank_num: u6 = @intFromEnum(card.rank) - 9;
        const discard_offset: u6 = if (to_play == true) 0 else 24;
        const num = rank_num + (suit_num * 6) + discard_offset;
        return @enumFromInt(num);
    }

    pub fn ToCard(self: Action) ActionError!Card {
        const num: u6 = @intFromEnum(self);
        if (num >= 48) return ActionError.NotConvertableToCard;
        const rank_num = (num % 6) + 9;
        const suit_num = (num % 24) / 6;

        return Card{ .suit = @enumFromInt(suit_num), .rank = @enumFromInt(rank_num) };
    }
};

pub const FlippedChoice = enum(u1) {
    PickedUp,
    TurnedDown,
};

test "action_from_str" {
    const expect = std.testing.expect;
    const expectErr = std.testing.expectError;

    const act_str = "Pick";

    const act = try Action.FromStr(act_str[0..]);

    try expect(act == Action.Pick);

    try expectErr(Action.ActionError.StrNotConvertable, Action.FromStr("playS9"));
}

test "action_from_card" {
    const expect = std.testing.expect;

    var card = try Card.FromStr("S9");

    var act = Action.FromCard(card, true);
    try expect(act == Action.PlayS9);

    var act_d = Action.FromCard(card, false);
    try expect(act_d == Action.DiscardS9);

    card = try Card.FromStr("CA");

    act = Action.FromCard(card, true);
    try expect(act == Action.PlayCA);

    act_d = Action.FromCard(card, false);
    try expect(act_d == Action.DiscardCA);
}

test "card_from_action" {
    const expect = std.testing.expect;

    var act = Action.PlayC9;
    const card = try act.ToCard();
    try expect(card.eq(try Card.FromStr("C9")));

    try expect(Action.Pick.ToCard() == Action.ActionError.NotConvertableToCard);
    try expect(Action.CallClubs.ToCard() == Action.ActionError.NotConvertableToCard);
}
