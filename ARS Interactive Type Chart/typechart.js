var existing_combos = [
    // The number in each cell stands for the generation in which the combo was first introduced. 0 means it still does not exist. 8.5 means it is introduced in Legends: Arceus. 10 means it is exclusive to Generation AN1. 9 should not be used before 11/18/2022 when Violet and Scarlet release. Do not include Pokémon introduced in Zantaru, Silati, Xureen, or Tzarin, as these could include Gen X Pokémon and thus alter the meaning of Gen 10.
	//                                                                          C
    //              E           F                                               E
    //              L           I               P                               L
    //  N           E           G   P   G   F   S               D               E   G
    //  O       W   C   G       H   O   R   L   Y           G   R       S   F   S   L   <- Type 2
    //  R   F   A   T   R       T   I   O   Y   C       R   H   A   D   T   A   T   I
    //  M   I   T   R   A   I   I   S   U   I   H   B   O   O   G   A   E   I   I   T   Type 1
    //  A   R   E   I   S   C   N   O   N   N   I   U   C   S   O   R   E   R   A   C     |
    //  L   E   R   C   S   E   G   N   D   G   C   G   K   T   N   K   L   Y   L   H     v
    [   1,  0,  4,  0,  5,  0,  5,  0,  6,  1,  2,  0,  0,8.5,  7,  0,  0,  6,  0,  0], // NORMAL
    [   6,  1,  6,  0,  0, 10,  3,  9,  3,  1,  5,  8,  2,  7,  6,  7,  4, 10,  0, 10], // FIRE
    [   0, 10,  1,  2,  3,  1,  1,  1,  2,  1,  1,  7,  2,  5,  2,  3,  4,  6, 10, 10], // WATER
    [   6,  5,  5,  1,  5,  5,  9,  8,  0,  1,  7,  0,  0,  4,  6,  8,  2,  6,  0,  0], // ELECTRIC
    [   9,  9,  9,  0,  1,  4,  3,  1,  4,  2,  1, 10,  9,  7,  6,  3,  5,  6,  0,  0], // GRASS
    [   0,  8,  3,  0,  0,  3,  0, 10,  2,  1,  1,  8,8.5,  4,  0, 10,  7,  7, 10, 10], // ICE
    [   0,  0,  8,  0,  0,  7,  1,8.5,  0,  6,  3,  0,  0,  7,  9,  6,  4,  0,  0,  0], // FIGHTING
    [   9,  7,  6,  0,  0,  0,  4,  1,  1,  1,  8,  4,  0,  9,  6,  4,  0,  9,  0,  0], // POISON
    [ 8.5,  6,  0,  5,  9,  0,  9,  0,  1,  2,  3,  0,  1,  5,  3,  5,  5, 10,  0,  0], // GROUND
    [   0,  0,  8,  0,  0,  0,  0,  0,  0,  4,  0,  0,  0,  0,  6,  0,  8,  0,  0,  0], // FLYING
    [   8,  5,  0,  0,  2,  0,  4,  0,  0,  2,  1,  0,  0,  6,  7,  0,  7,  6, 10,  0], // PSYCHIC
    [   0,  5,  3,  5,  1,  0,  2,  1,  3,  1,  8,  1,  2,  3, 10,  9,  2,  7,  0,  0], // BUG
    [  10,  8,  1,  7,  3,  6,  5,  7,  1,  1,  3,  3,  2, 10,  6,  2,  4,  6, 10, 10], // ROCK
    [   0,  5,  0,  0,  6,  0,  9,  1,  7,  4,  0,  0,  0,  2,  4,  4,  9,  7,  0,  0], // GHOST
    [   9,  5,  9,  5,  0,  5,  7,  0,  4,  1,  3,  0,  0,  8,  1, 10,  0,  6, 10,  0], // DRAGON
    [   7,  2,  0,  0,  8,  2,  5,8.5,  9,  2,  6,  0,  0,  3,  5,  2,  5,  8,  0, 10], // DARK
    [   0,  0,  0,  0,  0,  0,  5,  0,  2,  2,  3,  0,  3,  6,  4,  0,  3,  6,  0,  0], // STEEL
    [   0,  0,  0,  0,  0,  0,  9,  0,  0,  6,  0,  0,  0,  0,  0,  0,  9,  6,  0,  0], // FAIRY
	[   0,  0,  0,  0,  0,  0,  0, 10,  0,  0, 10,  0,  0, 10, 10, 10, 10, 10, 10,  0], // CELESTIAL
	[   0,  0,  0,  0, 10,  0,  0,  0,  0,  0, 10,  0,  0, 10,  0,  0,  0,  0,  0,  0]  // GLITCH
];

var multipliers = {
    0: {mul: 0, message: "It doesn't affect the target!", display: "&times;0", css_class: "type-ne", offensive_name: "ineffective", defensive_name: "immune", summary_name: "0x"},
    0.25: {mul: 0.25, message: "It's not very effective...", display: "&times;&frac14;", css_class: "type-dnve", offensive_name: "doubly not very effective", defensive_name: "doubly resistant", summary_name: "0.25x or less"},
    0.5: {mul: 0.5, message: "It's not very effective...", display: "&times;&frac12", css_class: "type-nve", offensive_name: "not very effective", defensive_name: "resistant", summary_name: "0.5x or less"},
    1: {mul: 1, message: "", display: "-", css_class: "", offensive_name: "neutral", defensive_name: "neutral", summary_name: "1x"},
    2: {mul: 2, message: "It's super effective!", display: "&times;2", css_class: "type-se", offensive_name: "super effective", defensive_name: "weak", summary_name: "2x or more"},
    4: {mul: 4, message: "It's super effective!", display: "&times;4", css_class: "type-dse", offensive_name: "doubly super effective", defensive_name: "doubly weak", summary_name: "4x"}
};

// Returns an inverted version of the given type chart, Inverse Battle-style.
function inverse(type_chart) {
    var inverse_chart = [];
    for (var i = 0; i < type_chart.length; i++) {
        inverse_chart[i] = [];
        for (var j = 0; j < type_chart[i].length; j++) {
            inverse_chart[i][j] = (type_chart[i][j] < 1 ? 2 : (type_chart[i][j] > 1 ? 0.5 : 1));
        }
    }
    return inverse_chart;
}

var gen1_chart = {
    id: 'gen1',
    name: "Gen I type chart",
    types: ["Normal", "Fire", "Water", "Electric", "Grass", "Ice", "Fighting", "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon"],
    type_chart: [
        //                E              F
        //                L              I                   P
        // N              E              G    P    G    F    S                   D
        // O         W    C    G         H    O    R    L    Y              G    R  <- Defending type
        // R    F    A    T    R         T    I    O    Y    C         R    H    A
        // M    I    T    R    A    I    I    S    U    I    H    B    O    O    G   Attack type
        // A    R    E    I    S    C    N    O    N    N    I    U    C    S    O        |
        // L    E    R    C    S    E    G    N    D    G    C    G    K    T    N        v
        [  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, 0.5,   0,   1], // NORMAL
        [  1, 0.5, 0.5,   1,   2,   2,   1,   1,   1,   1,   1,   2, 0.5,   1, 0.5], // FIRE
        [  1,   2, 0.5,   1, 0.5,   1,   1,   1,   2,   1,   1,   1,   2,   1, 0.5], // WATER
        [  1,   1,   2, 0.5, 0.5,   1,   1,   1,   0,   2,   1,   1,   1,   1, 0.5], // ELECTRIC
        [  1, 0.5,   2,   1, 0.5,   1,   1, 0.5,   2, 0.5,   1, 0.5,   2,   1, 0.5], // GRASS
        [  1,   1, 0.5,   1,   2, 0.5,   1,   1,   2,   2,   1,   1,   1,   1,   2], // ICE
        [  2,   1,   1,   1,   1,   2,   1, 0.5,   1, 0.5, 0.5, 0.5,   2,   0,   1], // FIGHTING
        [  1,   1,   1,   1,   2,   1,   1, 0.5, 0.5,   1,   1,   2, 0.5, 0.5,   1], // POISON
        [  1,   2,   1,   2, 0.5,   1,   1,   2,   1,   0,   1, 0.5,   2,   1,   1], // GROUND
        [  1,   1,   1, 0.5,   2,   1,   2,   1,   1,   1,   1,   2, 0.5,   1,   1], // FLYING
        [  1,   1,   1,   1,   1,   1,   2,   2,   1,   1, 0.5,   1,   1,   1,   1], // PSYCHIC
        [  1, 0.5,   1,   1,   2,   1, 0.5,   2,   1, 0.5,   2,   1,   1, 0.5,   1], // BUG
        [  1,   2,   1,   1,   1,   2, 0.5,   1, 0.5,   2,   1,   2,   1,   1,   1], // ROCK
        [  0,   1,   1,   1,   1,   1,   1,   1,   1,   1,   0,   1,   1,   2,   1], // GHOST
        [  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2], // DRAGON
    ]
};

var gen2_chart = {
    id: 'gen2',
    name: "Gen II-V type chart",
    types: ["Normal", "Fire", "Water", "Electric", "Grass", "Ice", "Fighting", "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Dark", "Steel"],
    type_chart: [
        //                E              F
        //                L              I                   P
        // N              E              G    P    G    F    S                   D
        // O         W    C    G         H    O    R    L    Y              G    R         S  <- Defending type
        // R    F    A    T    R         T    I    O    Y    C         R    H    A    D    T
        // M    I    T    R    A    I    I    S    U    I    H    B    O    O    G    A    E   Attack type
        // A    R    E    I    S    C    N    O    N    N    I    U    C    S    O    R    E        |
        // L    E    R    C    S    E    G    N    D    G    C    G    K    T    N    K    L        v
        [  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, 0.5,   0,   1,   1, 0.5], // NORMAL
        [  1, 0.5, 0.5,   1,   2,   2,   1,   1,   1,   1,   1,   2, 0.5,   1, 0.5,   1,   2], // FIRE
        [  1,   2, 0.5,   1, 0.5,   1,   1,   1,   2,   1,   1,   1,   2,   1, 0.5,   1,   1], // WATER
        [  1,   1,   2, 0.5, 0.5,   1,   1,   1,   0,   2,   1,   1,   1,   1, 0.5,   1,   1], // ELECTRIC
        [  1, 0.5,   2,   1, 0.5,   1,   1, 0.5,   2, 0.5,   1, 0.5,   2,   1, 0.5,   1, 0.5], // GRASS
        [  1, 0.5, 0.5,   1,   2, 0.5,   1,   1,   2,   2,   1,   1,   1,   1,   2,   1, 0.5], // ICE
        [  2,   1,   1,   1,   1,   2,   1, 0.5,   1, 0.5, 0.5, 0.5,   2,   0,   1,   2,   2], // FIGHTING
        [  1,   1,   1,   1,   2,   1,   1, 0.5, 0.5,   1,   1,   1, 0.5, 0.5,   1,   1,   0], // POISON
        [  1,   2,   1,   2, 0.5,   1,   1,   2,   1,   0,   1, 0.5,   2,   1,   1,   1,   2], // GROUND
        [  1,   1,   1, 0.5,   2,   1,   2,   1,   1,   1,   1,   2, 0.5,   1,   1,   1, 0.5], // FLYING
        [  1,   1,   1,   1,   1,   1,   2,   2,   1,   1, 0.5,   1,   1,   1,   1,   0, 0.5], // PSYCHIC
        [  1, 0.5,   1,   1,   2,   1, 0.5, 0.5,   1, 0.5,   2,   1,   1, 0.5,   1,   2, 0.5], // BUG
        [  1,   2,   1,   1,   1,   2, 0.5,   1, 0.5,   2,   1,   2,   1,   1,   1,   1, 0.5], // ROCK
        [  0,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2,   1,   1,   2,   1, 0.5, 0.5], // GHOST
        [  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2,   1, 0.5], // DRAGON
        [  1,   1,   1,   1,   1,   1, 0.5,   1,   1,   1,   2,   1,   1,   2,   1, 0.5, 0.5], // DARK
        [  1, 0.5, 0.5, 0.5,   1,   2,   1,   1,   1,   1,   1,   1,   2,   1,   1,   1, 0.5]  // STEEL
    ]
};

var gen6_chart = {
    id: 'gen6',
    name: "Gen VI+ type chart",
    types: ["Normal", "Fire", "Water", "Electric", "Grass", "Ice", "Fighting", "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Dark", "Steel", "Fairy"],
    type_chart: [
        //                E              F
        //                L              I                   P
        // N              E              G    P    G    F    S                   D
        // O         W    C    G         H    O    R    L    Y              G    R         S    F  <- Defending type
        // R    F    A    T    R         T    I    O    Y    C         R    H    A    D    T    A
        // M    I    T    R    A    I    I    S    U    I    H    B    O    O    G    A    E    I   Attack type
        // A    R    E    I    S    C    N    O    N    N    I    U    C    S    O    R    E    R        |
        // L    E    R    C    S    E    G    N    D    G    C    G    K    T    N    K    L    Y        v
        [  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, 0.5,   0,   1,   1, 0.5,   1], // NORMAL
        [  1, 0.5, 0.5,   1,   2,   2,   1,   1,   1,   1,   1,   2, 0.5,   1, 0.5,   1,   2,   1], // FIRE
        [  1,   2, 0.5,   1, 0.5,   1,   1,   1,   2,   1,   1,   1,   2,   1, 0.5,   1,   1,   1], // WATER
        [  1,   1,   2, 0.5, 0.5,   1,   1,   1,   0,   2,   1,   1,   1,   1, 0.5,   1,   1,   1], // ELECTRIC
        [  1, 0.5,   2,   1, 0.5,   1,   1, 0.5,   2, 0.5,   1, 0.5,   2,   1, 0.5,   1, 0.5,   1], // GRASS
        [  1, 0.5, 0.5,   1,   2, 0.5,   1,   1,   2,   2,   1,   1,   1,   1,   2,   1, 0.5,   1], // ICE
        [  2,   1,   1,   1,   1,   2,   1, 0.5,   1, 0.5, 0.5, 0.5,   2,   0,   1,   2,   2, 0.5], // FIGHTING
        [  1,   1,   1,   1,   2,   1,   1, 0.5, 0.5,   1,   1,   1, 0.5, 0.5,   1,   1,   0,   2], // POISON
        [  1,   2,   1,   2, 0.5,   1,   1,   2,   1,   0,   1, 0.5,   2,   1,   1,   1,   2,   1], // GROUND
        [  1,   1,   1, 0.5,   2,   1,   2,   1,   1,   1,   1,   2, 0.5,   1,   1,   1, 0.5,   1], // FLYING
        [  1,   1,   1,   1,   1,   1,   2,   2,   1,   1, 0.5,   1,   1,   1,   1,   0, 0.5,   1], // PSYCHIC
        [  1, 0.5,   1,   1,   2,   1, 0.5, 0.5,   1, 0.5,   2,   1,   1, 0.5,   1,   2, 0.5, 0.5], // BUG
        [  1,   2,   1,   1,   1,   2, 0.5,   1, 0.5,   2,   1,   2,   1,   1,   1,   1, 0.5,   1], // ROCK
        [  0,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2,   1,   1,   2,   1, 0.5,   1,   1], // GHOST
        [  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2,   1, 0.5,   0], // DRAGON
        [  1,   1,   1,   1,   1,   1, 0.5,   1,   1,   1,   2,   1,   1,   2,   1, 0.5,   1, 0.5], // DARK
        [  1, 0.5, 0.5, 0.5,   1,   2,   1,   1,   1,   1,   1,   1,   2,   1,   1,   1, 0.5,   2], // STEEL
        [  1, 0.5,   1,   1,   1,   1,   2, 0.5,   1,   1,   1,   1,   1,   1,   2,   2, 0.5,   1], // FAIRY
    ]
};

var gen6_inverse_chart = {
    id: 'gen6_inverse',
    name: 'Gen VI inverse type chart',
    types: gen6_chart.types,
    type_chart: inverse(gen6_chart.type_chart)
};

var genAN1_chart = {
	id: 'genAN1',
	name: 'Gen AN-I type chart',
	types: ["Normal", "Fire", "Water", "Electric", "Grass", "Ice", "Fighting", "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Dark", "Steel", "Fairy", "Celestial", "Glitch"],
	type_chart: [
		//                                                                                           C
		//                E              F                                                           E
        //                L              I                   P                                       L
        // N              E              G    P    G    F    S                   D                   E    G
        // O         W    C    G         H    O    R    L    Y              G    R         S    F    S    L  <- Defending type
        // R    F    A    T    R         T    I    O    Y    C         R    H    A    D    T    A    T    I
        // M    I    T    R    A    I    I    S    U    I    H    B    O    O    G    A    E    I    I    T   Attack type
        // A    R    E    I    S    C    N    O    N    N    I    U    C    S    O    R    E    R    A    C        |
        // L    E    R    C    S    E    G    N    D    G    C    G    K    T    N    K    L    Y    L    H        v
        [  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, 0.5,   0,   1,   1, 0.5,   1, 0.5,   1], // NORMAL
        [  1, 0.5, 0.5,   1,   2,   2,   1,   1,   1,   1,   1,   2, 0.5,   1, 0.5,   1,   2,   1,   1,   1], // FIRE
        [  1,   2, 0.5,   1, 0.5,   1,   1,   1,   2,   1,   1,   1,   2,   1, 0.5,   1,   1,   1, 0.5,   2], // WATER
        [  1,   1,   2, 0.5, 0.5,   1,   1,   1,   0,   2,   1,   1,   1,   1, 0.5,   1,   1,   1,   2, 0.5], // ELECTRIC
        [  1, 0.5,   2,   1, 0.5,   1,   1, 0.5,   2, 0.5,   1, 0.5,   2,   1, 0.5,   1, 0.5,   1,   1,   1], // GRASS
        [  1, 0.5, 0.5,   1,   2, 0.5,   1,   1,   2,   2,   1,   1,   1,   1,   2,   1, 0.5,   1,   1,   1], // ICE
        [  2,   1,   1,   1,   1,   2,   1, 0.5,   1, 0.5, 0.5, 0.5,   2,   0,   1,   2,   2, 0.5, 0.5, 0.5], // FIGHTING
        [  1,   1,   1,   1,   2,   1,   1, 0.5, 0.5,   1,   1,   1, 0.5, 0.5,   1,   1,   0,   2,   1, 0.5], // POISON
        [  1,   2,   1,   2, 0.5,   1,   1,   2,   1,   0,   1, 0.5,   2,   1,   1,   1,   2,   1, 0.5,   1], // GROUND
        [  1,   1,   1, 0.5,   2,   1,   2,   1,   1,   1,   1,   2, 0.5,   1,   1,   1, 0.5,   1,   1, 0.5], // FLYING
        [  1,   1,   1,   1,   1,   1,   2,   2,   1,   1, 0.5,   1,   1,   1,   1,   0, 0.5,   1, 0.5,   2], // PSYCHIC
        [  1, 0.5,   1,   1,   2,   1, 0.5, 0.5,   1, 0.5,   2,   1,   1, 0.5,   1,   2, 0.5,   2,   1,   1], // BUG
        [  1,   2,   1,   1,   1,   2, 0.5,   1, 0.5,   2,   1,   2,   1,   1,   1,   1, 0.5,   1, 0.5,   1], // ROCK
        [  0,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2,   1,   1,   2,   1, 0.5,   1,   1,   2,   1], // GHOST
        [  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2,   1, 0.5,   0,   1,   1], // DRAGON
        [  1,   1,   1,   1,   1,   1, 0.5,   1,   1,   1,   2,   1,   1,   2,   1, 0.5,   1, 0.5,   2,   1], // DARK
        [  1, 0.5, 0.5, 0.5,   1,   2,   1,   1,   1,   1,   1,   1,   2,   1,   1,   1, 0.5,   2, 0.5,   1], // STEEL
        [  1, 0.5,   1,   1,   1,   1,   2, 0.5,   1,   1,   1,   1,   1,   1,   2,   2, 0.5,   1,   1,   2], // FAIRY
		[  1,   1,   2,   1,   1, 0.5,   1,   1,   2,   1, 0.5,   1,   1,   1, 0.5,   1,   1, 0.5, 0.5,   2], // CELESTIAL
		[  1,   1, 0.5, 0.5,   1,   1,   1,   1,   1,   1,   2,   1, 0.5,   1,   2,   1,   2,   1, 0.5,   2], // GLITCH
	]
}

var base_charts = {
    'gen1': gen1_chart,
    'gen2': gen2_chart,
    'gen6': gen6_chart,
    'gen6_inverse': gen6_inverse_chart,
	'genAN1': genAN1_chart
};

function combo_name(type1, type2) {
    if (type1.index == type2.index) {
        return type1.name();
    }
    else {
        return type1.name() + "/" + type2.name();
    }
}

function pluralize(number, word, plural_word) {
    if (!plural_word) {
        plural_word = word + "s";
    }
    if (number == 1) {
        return number + " " + word;
    }
    else {
        return number + " " + plural_word;
    }
}

function clear_computed(object) {
    // Dispose of all computed observables on this object. Necessary to prevent memory leaks when we recalculate types or rows.
    for (key in object) {
        if (object.hasOwnProperty(key)) {
            if (ko.isComputed(object[key])) {
                object[key].dispose();
            }
            else if (ko.isObservable(object[key]) && object[key].indexOf) {
                // An observable array: recursively clear computed
                ko.utils.arrayForEach(object[key](), clear_computed);
            }
        }
    }
}

function combo_exists(chart, type1, type2) {
    if (type1.custom || type2.custom) {
        return false;
    }
    var existing_gen = chart.existing_gen();
    var exists_in = existing_combos[type1.real_index][type2.real_index];
    if (chart.existing_symmetrical()) {
        var reverse_exists_in = existing_combos[type2.real_index][type1.real_index];
        if (exists_in > 0 && reverse_exists_in > 0) {
            return Math.min(exists_in, reverse_exists_in) <= existing_gen;
        }
        else {
            // At least one of exists_in and reverse_exists_in is zero
            exists_in = Math.max(exists_in, reverse_exists_in);
        }
    }
    return exists_in > 0 && exists_in <= existing_gen;
}

function Type(index, name, real_index) {
    this.index = index;
    this.name = ko.observable(name);
    this.name.deferUpdates = false;
    this.real_index = real_index;
    this.custom = (real_index == -1);

    this.attack = function(chart, type1, type2) {
        if (type2 === undefined || type1.index == type2.index) {
            return chart.rows()[this.index].cells()[type1.index].multiplier();
        }
        else {
            return chart.rows()[this.index].cells()[type1.index].multiplier() * chart.rows()[this.index].cells()[type2.index].multiplier();
        }
    }
}

function TypeChartCell(type1, type2, chart, multiplier) {
    var self = this;

    self.chart = chart;
    self.type1 = type1;
    self.type2 = type2;

    self.multiplier = ko.observable(multiplier);

    self.cell_obj = ko.computed({read: function() {
        return self.chart.mode().get_cell_obj.call(self);
    }, deferEvaluation: true});

    self.exists = ko.computed(function() {
        return self.cell_obj().exists;
    });

    self.value = ko.computed(function() {
        return self.cell_obj().value;
    });

    self.content = ko.computed(function() {
        return self.cell_obj().display;
    });

    self.title = ko.computed(function() {
        return self.cell_obj().title;
    });

    self.css_class = ko.computed(function() {
        return self.chart.mode().get_cell_class.call(self);
    });

    self.cycle_multiplier = function(data, event) {
        if (self.chart.mode().combos || !self.type1.custom && !self.type2.custom && !self.chart.enable_edit_existing()) {
            return false;
        }
        event.stopPropagation();
        event.preventDefault();
        var next_mul = 1;
        var multipliers = [1, 2, 0.5, 0]; // We want to cycle through them in this order
        for (var i = 0; i < multipliers.length; i++) {
            if (multipliers[i] == self.value()) {
                next_mul = multipliers[(i + 1) % multipliers.length];
                break;
            }
        }
        self.multiplier(next_mul);
    };
}

function get_row_multiplier_summary(get_title) {
    var multiplier_array = this.chart.mode().multipliers;
    var ar = [];

    var counts = {};

    ko.utils.arrayForEach(multiplier_array, function(multiplier) {
        counts[multiplier] = 0;
    });

    for (var i = 0; i < this.cells().length; i++) {
        if (!this.chart.mode().combos || !this.chart.highlight_existing() || this.cells()[i].exists()) {
            counts[this.cells()[i].value()]++;
        }
    }

    var row = this;

    ko.utils.arrayForEach(multiplier_array, function(multiplier) {
        var mul_obj = multipliers[multiplier];
        var count = counts[multiplier];
        ar.push({css_class: mul_obj.css_class + " summary", content: count, attr: {title: get_title(row, count, mul_obj), 'data-type-row': row.type.index}});
    });
    return ar;
}

function TypeChartRow(type, chart, multipliers) {
    var self = this;

    self.type = type;
    self.chart = chart;

    self.cells = ko.observableArray(ko.utils.arrayMap(chart.type_objs.peek(), function(type) {
        return new TypeChartCell(self.type, type, chart, multipliers ? multipliers[type.index] : 1);
    }));

    self.summary_total = ko.computed(function() {
        return chart.mode().get_row_total.call(self);
    });

    self.summary_cells = ko.computed({read: function() {
        return chart.mode().get_row_summary_cells.call(self);
    }, deferEvaluation: true});
}

var simple_mode = {
    id: "simple",
    name: "Simple mode",
    css_class: "single-mode",
    multipliers: [0, 0.5, 1, 2],
    combos: false,
    has_add_type: true,
    has_type_selection: false,
    has_moveset_selection: false,
    has_relation_selection: false,
    horizontal_label: 'Attack',
    vertical_label: 'Target',
    get_cell_class: function() {
        var css_class = multipliers[this.multiplier()].css_class;
        if (this.type1.custom || this.type2.custom) {
            css_class += " custom";
        }
        return css_class;
    },
    get_cell_obj: function() {
        var mul_obj = multipliers[this.multiplier()];
        var title = this.type1.name() + " " + mul_obj.offensive_name + " against " + this.type2.name();
        if (this.type1.custom || this.type2.custom || this.chart.enable_edit_existing()) {
            title += " (click to change)";
        }
        return {value: mul_obj.mul, display: mul_obj.display, title: title, exists: true};
    },
    get_row_total: function() {
        return 0;
    },
    get_row_summary_cells: function() {
        return get_row_multiplier_summary.call(this, function(row, count, mul_obj) {
            return pluralize(count, 'type') + ' ' + mul_obj.defensive_name + ' to ' + row.type.name();
        });
    },
    get_summary_rows: function() {
        var multiplier_array = this.mode().multipliers;
        var ar = [];

        var counts = {};

        var chart = this;

        ko.utils.arrayForEach(multiplier_array, function(multiplier) {
            counts[multiplier] = [];

            for (var t = 0; t < chart.rows().length; t++) {
                counts[multiplier][t] = 0;
            }
        });

        ko.utils.arrayForEach(this.rows(), function(row) {
            ko.utils.arrayForEach(row.cells(), function(cell) {
                counts[cell.multiplier()][cell.type2.index]++;
            });
        });

        ko.utils.arrayForEach(multiplier_array, function(multiplier) {
            var mul_obj = multipliers[multiplier];
            var multiplier_row = [];
            for (var t = 0; t < counts[multiplier].length; t++) {
                var count = counts[multiplier][t];
                multiplier_row.push({css_class: mul_obj.css_class + " summary", content: count, attr: {title: pluralize(count, 'type') + ' ' + mul_obj.offensive_name + ' against ' + chart.rows()[t].type.name(), 'data-type-col': chart.rows()[t].type.index}});
            }
            ar.push(multiplier_row);
        });
        return ar;
    }
};

var filtered_mode = {
    id: "filtered",
    name: "Filtered simple mode",
    css_class: "filtered-mode",
    multipliers: [0, 0.25, 0.5, 1, 2, 4],
    combos: true,
    has_add_type: false,
    has_type_selection: true,
    has_moveset_selection: false,
    has_relation_selection: false,
    horizontal_label: 'Attack',
    vertical_label: 'Target type 2',
    get_cell_class: function() {
        var css_class = multipliers[this.value()].css_class;
        if (this.exists() && this.chart.highlight_existing()) {
            css_class += " highlight-combo";
        }
        return css_class;
    },
    get_cell_obj: function() {
        var filter_type = this.chart.filter_type();
        var mul_obj = multipliers[this.type1.attack(this.chart, filter_type || this.type2, this.type2)];
        var title = this.type1.name() + " " + mul_obj.offensive_name + " against " + combo_name(filter_type || this.type2, this.type2);
        var exists = combo_exists(this.chart, this.chart.filter_type() || this.type2, this.type2);
        return {value: mul_obj.mul, display: mul_obj.display, title: title, exists: exists};
    },
    get_row_total: function() {
        return 0;
    },
    get_row_summary_cells: function() {
        return get_row_multiplier_summary.call(this, function(row, count, mul_obj) {
            return pluralize(count, (row.chart.filter_type() ? row.chart.filter_type().name() + ' combo' : 'pure type')) + ' ' + mul_obj.defensive_name + ' to ' + row.type.name();
        });
    },
    get_summary_rows: function() {
        var multiplier_array = this.mode().multipliers;
        var ar = [];

        var counts = {};

        var chart = this;

        ko.utils.arrayForEach(multiplier_array, function(multiplier) {
            counts[multiplier] = [];

            for (var t = 0; t < chart.rows().length; t++) {
                counts[multiplier][t] = 0;
            }
        });

        ko.utils.arrayForEach(this.rows(), function(row) {
            ko.utils.arrayForEach(row.cells(), function(cell) {
                counts[cell.value()][cell.type2.index]++;
            });
        });

        ko.utils.arrayForEach(multiplier_array, function(multiplier) {
            var mul_obj = multipliers[multiplier];
            var multiplier_row = [];
            for (var t = 0; t < counts[multiplier].length; t++) {
                var count = counts[multiplier][t];
                multiplier_row.push({css_class: mul_obj.css_class + " summary", content: count, attr: {title: pluralize(count, 'type') + ' ' + mul_obj.offensive_name + ' against ' + combo_name(chart.filter_type() || chart.rows()[t].type, chart.rows()[t].type), 'data-type-col': chart.rows()[t].type.index}});
            }
            ar.push(multiplier_row);
        });
        return ar;
    }
};

var moveset_mode = {
    id: "moveset",
    name: "Moveset coverage mode",
    css_class: "combo-mode",
    multipliers: [0, 0.25, 0.5, 1, 2, 4],
    combos: true,
    has_add_type: false,
    has_type_selection: false,
    has_moveset_selection: true,
    has_relation_selection: false,
    horizontal_label: 'Type 1',
    vertical_label: 'Type 2',
    get_cell_class: function() {
        var css_class = multipliers[this.value()].css_class;
        if (this.exists() && this.chart.highlight_existing()) {
            css_class += " highlight-combo";
        }
        return css_class;
    },
    get_cell_obj: function() {
        var mul = -1;
        var cell = this;
        ko.utils.arrayForEach(this.chart.attack_types(), function(attack_type) {
            mul = Math.max(mul, attack_type.attack(cell.chart, cell.type1, cell.type2));
        });
        var mul_obj = multipliers[mul == -1 ? 1 : mul];
        var title = combo_name(this.type1, this.type2) + " " + mul_obj.defensive_name + " to " + (this.chart.attack_types().length == 1 ? this.chart.attack_types()[0].name() : "selected types");
        var exists = combo_exists(this.chart, this.type1, this.type2);
        return {value: mul_obj.mul, display: mul_obj.display, title: title, exists: exists};
    },
    get_row_total: function() {
        return 0;
    },
    get_row_summary_cells: function() {
        return get_row_multiplier_summary.call(this, function(row, count, mul_obj) {
            return pluralize(count, row.type.name() + ' combo') + ' ' + mul_obj.defensive_name + ' to ' + (row.chart.attack_types().length == 1 ? row.chart.attack_types()[0].name() : "selected types");
        });
    },
    get_summary_rows: function() {
        var multiplier_array = this.mode().multipliers;
        var ar = [];
        ar.push([{css_class: "no-highlight", content: '', attr: {colspan: this.rows().length}}]);
        for (var i = 0; i < multiplier_array.length; i++) {
            var mul_obj = multipliers[multiplier_array[i]];
            var count = 0;

            ko.utils.arrayForEach(this.rows(), function(row) {
                count += row.summary_cells()[i].content;
            });

            ar[0].push({css_class: mul_obj.css_class + " summary no-highlight", content: count, attr: {title: pluralize(count, ' type combination') + ' ' + mul_obj.defensive_name + ' to ' + (this.attack_types().length == 1 ? this.attack_types()[0].name() : "selected types")}});
        }
        return ar;
    }
};

var summary_mode = {
    id: "summary",
    name: "Defensive summary mode",
    css_class: "summary-mode",
    multipliers: [0, 0.25, 0.5, 1, 2, 4],
    combos: true,
    has_add_type: false,
    has_type_selection: false,
    has_moveset_selection: false,
    has_relation_selection: true,
    horizontal_label: 'Type 1',
    vertical_label: 'Type 2',
    // get_cell_class has to be separate - otherwise we get an infinite loop because count_boundaries() has to check the values of all cells.
    get_cell_class: function() {
        var count = this.value();
        var bounds = this.chart.count_boundaries();
        var classes = ['type-ne', 'type-dnve', 'type-nve', '', 'type-se', 'type-dse'];
        var css_class = classes[Math.round((count - bounds.lowest) * 5 / (bounds.highest - bounds.lowest))];
        if (this.exists() && this.chart.highlight_existing()) {
            css_class += " highlight-combo";
        }
        return css_class;
    },
    get_cell_obj: function() {
        var relation = this.chart.count_relation();
        var relation_cmp = relation.mul - 1; // Why on earth we're doing this will be clear in a moment
        var count = 0;
        var relevant_types = [];
        var cell = this;

        ko.utils.arrayForEach(this.chart.type_objs(), function(type) {
            try {
                var multiplier = type.attack(cell.chart, cell.type1, cell.type2);
            }
            catch (e) {
                var multiplier = 1;
            }
            var multiplier_cmp = multiplier - 1;
            if (multiplier_cmp == relation_cmp || multiplier_cmp > relation_cmp && relation_cmp > 0 || multiplier_cmp < relation_cmp && relation_cmp < 0) {
                count++;
                relevant_types.push(type.name() + " " + multiplier + "x");
            }
        });

        var title = pluralize(count, "type") + " " + relation.summary_name + " against " + combo_name(this.type1, this.type2) + (count > 0 ? " (" + relevant_types.join(", ") + ")" : "");
        var exists = combo_exists(this.chart, this.type1, this.type2);
        return {value: count, display: count, title: title, exists: exists};
    },
    get_row_total: function() {
        var count = 0;
        var sum = 0;
        var row = this;
        ko.utils.arrayForEach(this.cells(), function(cell) {
            if (cell.exists() || !row.chart.highlight_existing() || row.chart.rows()[cell.type2.index].cells()[row.type.index].exists()) {
                count++;
                sum += cell.value();
            }
        });
        return (count > 0 ? Math.round(sum * 100 / count) / 100 : 0);
    },
    get_row_summary_cells: function() {
        var relation = this.chart.count_relation();
        var bounds = this.chart.row_count_boundaries();
        var summary = this.summary_total();
        var classes = ['type-ne', 'type-dnve', 'type-nve', '', 'type-se', 'type-dse'];
        var css_class = classes[Math.round((summary - bounds.lowest) * 5 / (bounds.highest - bounds.lowest))];
        return [{css_class: css_class + " summary", content: summary, attr: {title: pluralize(summary, "type") + " " + relation.summary_name + " against " + this.type.name() + " combinations on average", 'data-type-row': this.type.index}}];
    },
    get_summary_rows: function() {
        return [];
    }
};

var defense_mode = {
    id: "defense",
    name: "Overall defense mode",
    css_class: "defense-mode",
    multipliers: [0, 0.25, 0.5, 1, 2, 4],
    combos: true,
    has_add_type: false,
    has_type_selection: false,
    has_moveset_selection: false,
    has_relation_selection: false,
    has_multi_type_selection: true,
    horizontal_label: 'Type 1',
    vertical_label: 'Type 2',
    // get_cell_class has to be separate - otherwise we get an infinite loop because count_boundaries() has to check the values of all cells.
    get_cell_class: function() {
        var count = this.value();
        var bounds = this.chart.count_boundaries();
        var classes = ['type-dse', 'type-se', '', 'type-nve', 'type-dnve', 'type-ne'];
        var css_class = classes[Math.round((count - bounds.lowest) * 5 / (bounds.highest - bounds.lowest))];
        if (this.exists() && this.chart.highlight_existing()) {
            css_class += " highlight-combo";
        }
        return css_class;
    },
    get_cell_obj: function() {
        var cell = this;
        var sum = 0;
        var selected_types = this.chart.selected_types();

        ko.utils.arrayForEach(selected_types, function(type) {
            try {
                sum += type.attack(cell.chart, cell.type1, cell.type2);
            }
            catch (e) {
                sum += 1;
            }
        });

        if (selected_types.length > 0) {
            var average = sum / selected_types.length;
        }
        else {
            var average = 1;
        }

        var title = combo_name(this.type1, this.type2) + " has an average defensive multiplier of " + Math.round(average * 100) / 100;
        var exists = combo_exists(this.chart, this.type1, this.type2);
        return {value: average, display: Math.round(average * 100) / 100, title: title, exists: exists};
    },
    get_row_total: function() {
        var count = 0;
        var sum = 0;
        var row = this;
        ko.utils.arrayForEach(this.cells(), function(cell) {
            if (cell.exists() || !row.chart.highlight_existing() || row.chart.rows()[cell.type2.index].cells()[row.type.index].exists()) {
                count++;
                sum += cell.value();
            }
        });
        return (count > 0 ? Math.round(sum * 100 / count) / 100 : 0);
    },
    get_row_summary_cells: function() {
        var bounds = this.chart.row_count_boundaries();
        var summary = this.summary_total();
        var classes = ['type-dse', 'type-se', '', 'type-nve', 'type-dnve', 'type-ne'];
        var css_class = classes[Math.round((summary - bounds.lowest) * 5 / (bounds.highest - bounds.lowest))];
        return [{css_class: css_class + " summary", content: summary, attr: {title: this.type.name() + " combos have an average defensive multiplier of " + summary, 'data-type-row': this.type.index}}];
    },
    get_summary_rows: function() {
        return [];
    }
};

$(document).ready(function() {
    function remove_highlights(event) {
        if (!$(event.relatedTarget).is("#typechart, #typechart *:not(td, th)")) {
            $("#typechart").removeClass("highlight-cell");
            $("#typechart .highlight").removeClass("highlight");
        }
    }

    function typeChartViewModel() {
        var self = this;

        self.has_localstorage = (function() {
            try {
                return 'localStorage' in window && window['localStorage'] !== null;
            }
            catch(e) {
                return false;
            }
        })();

        self.highlight_existing = ko.observable(false);

        self.existing_symmetrical = ko.observable(true);

        self.existing_gen = ko.observable(10);

        self.enable_edit_existing = ko.observable(false);

        self.mode = ko.observable(simple_mode);

        self.base_chart = ko.observable(genAN1_chart);

        function base_type_objs() {
            var base_chart = self.base_chart();
            var ar = [];
            for (var t = 0; t < base_chart.types.length; t++) {
                ar.push(new Type(t, base_chart.types[t], t));
            }
            return ar;
        }

        self.type_objs = ko.observableArray();

        if (self.has_localstorage && localStorage.getItem("custom_typechart")) {
            var ar = [];
            self.stored_types = $.parseJSON(localStorage.getItem("custom_typechart"));
            // Backwards-compatibility
            if (!('types' in self.stored_types)) {
                self.stored_types = {
                    base: 'gen2',
                    types: self.stored_types
                };
            }
            var base_chart = base_charts[self.stored_types.base];
            self.base_chart(base_chart);
            ko.utils.arrayForEach(self.stored_types.types, function(type) {
                if (type.index in base_chart.type_chart && (type.name != base_chart.types[type.index] || type.multipliers.slice(0, base_chart.types.length).join(',') != base_chart.type_chart[type.index].join(','))) {
                    // This should correspond to an existing type, but something has been edited
                    self.enable_edit_existing(true);
                }
                ar.push(new Type(type.index, type.name, type.real_index));
            });
            self.type_objs(ar);
        }
        else {
            self.type_objs(base_type_objs());
            self.stored_types = {
                base: self.base_chart().id,
                types: ko.utils.arrayMap(self.type_objs(), function(type) {
                    return {index: type.index, name: type.name(), multipliers: self.base_chart().type_chart[type.index], real_index: type.real_index}
                })
            };
        }

        self.attack_type1 = ko.observable();
        self.attack_type2 = ko.observable();
        self.attack_type3 = ko.observable();
        self.attack_type4 = ko.observable();
        self.attack_type5 = ko.observable();
        self.attack_type6 = ko.observable();
        self.attack_type7 = ko.observable();
        self.attack_type8 = ko.observable();
        self.attack_type9 = ko.observable();
        self.attack_type10 = ko.observable();

        self.attack_types = ko.computed(function() {
            var ar = [];
            for (var i = 1; i <= 10; i++) {
                if (self['attack_type' + i]() !== undefined) {
                    ar.push(self['attack_type' + i]());
                }
            }
            return ar;
        });
    
        self.selected_types = ko.observableArray(ko.utils.arrayMap(self.type_objs(), function(type) { return type; }));

        self.mul_objs = ko.utils.arrayMap([0, 0.25, 0.5, 1, 2, 4], function(multiplier) {
            return multipliers[multiplier];
        });

        self.count_relation = ko.observable(self.mul_objs[0]);

        self.filter_type = ko.observable();

        self.css_class = ko.computed(function() {
            var css_class = self.mode().css_class;
            if (self.mode().combos && self.highlight_existing()) {
                css_class += " highlight-combos";
            }
            if (!self.mode().combos && self.enable_edit_existing()) {
                css_class += " enable-edit-existing";
            }
            return css_class;
        })

        self.rows = ko.observableArray(ko.utils.arrayMap(self.type_objs(), function(type) {
            return new TypeChartRow(type, self, self.stored_types.types[type.index].multipliers);
        }));

        self.set_base = function(base_chart) {
            // Change the base chart of a chart.
            // This is a significant operation because while we want to wipe any changes to relations between the types in the base chart, we want to keep all of the user's custom types and their relations both to existing and custom types.
            var type_objs = base_type_objs();
            var attack_types = self.attack_types();
            var custom_types = ko.utils.arrayFilter(self.type_objs(), function(type) {
                return type.custom;
            });

            ko.utils.arrayForEach(custom_types, function(type) {
                type.new_index = type_objs.length;
                type_objs.push(new Type(type.new_index, type.name(), -1));
            });

            var new_attack_types = ko.utils.arrayMap(attack_types, function(type) {
                if (type.custom) {
                    // It's a custom type, and resetting the base chart keeps customs, so we can just use the new object for the custom type
                    return type_objs[ko.utils.arrayFirst(custom_types, function(type2) { return type2.index == type.index; }).new_index];
                }
                else {
                    // It's a real type, so use the same real type
                    return (type_objs[type.real_index].custom ? null : type_objs[type.real_index]);
                }
            });

            // Construct a new type chart with all of the types in it.
            var new_type_chart = ko.utils.arrayMap(type_objs, function(type) {
                if (!type.custom) {
                    // It's a regular old type. Start off giving it the multipliers given in the base type chart, plus neutral for all custom types.
                    var multipliers = base_chart.type_chart[type.real_index];
                    ko.utils.arrayForEach(custom_types, function(custom_type) {
                        multipliers.push(1);
                    });
                    return multipliers;
                }
                else {
                    // It's a custom type. Start off with all multipliers being 1.
                    return ko.utils.arrayMap(type_objs, function(type) {
                        return 1;
                    });
                }
            });

            // Now modify the multipliers in the new type chart according to the current type chart.
            // First, do it for existing type rows.
            ko.utils.arrayForEach(self.rows(), function(row) {
                if (!row.type.custom && row.type.real_index in base_chart.type_chart) {
                    // This row corresponds to an existing type that's in this chart - set its multipliers for custom types but leave the ones for existing types alone (we've already set them according to the base chart)
                    ko.utils.arrayForEach(custom_types, function(type) {
                        new_type_chart[row.type.real_index][type.new_index] = row.cells()[type.index].multiplier();
                    });
                }
            });

            // Now do it for custom types. (We have to do it like this because the custom_types array includes the new index for all the types, which the actual type objects accessible from the rows don't.)
            ko.utils.arrayForEach(custom_types, function(type) {
                ko.utils.arrayForEach(self.rows()[type.index].cells(), function(cell) {
                    if (!cell.type2.custom) {
                        new_type_chart[type.new_index][cell.type2.real_index] = cell.multiplier();
                    }
                });

                ko.utils.arrayForEach(custom_types, function(type2) {
                    new_type_chart[type.new_index][type2.new_index] = self.rows()[type.index].cells()[type2.index].multiplier();
                });
            });

            // Now we're all set: set type_objs and create new rows
            ko.utils.arrayForEach(self.type_objs(), clear_computed);
            self.type_objs(type_objs);

            ko.utils.arrayForEach(self.rows(), clear_computed);

            self.rows(ko.utils.arrayMap(self.type_objs(), function(type) {
                return new TypeChartRow(type, self, new_type_chart[type.index]);
            }));

            for (var i = 0; i < new_attack_types.length; i++) {
                self['attack_type' + (i + 1)](new_attack_types[i]);
            }

            self.selected_types(type_objs);
        };

        self.enable_edit_existing.subscribe(function(value) {
            if (!value) {
                // We're setting edit_existing to false
                self.set_base(self.base_chart());
            }
        });

        self.reset_types = function() {
            // We don't want to mess with self.stored_types here
            ko.utils.arrayForEach(self.type_objs(), clear_computed);
            self.type_objs(base_type_objs());
            self.selected_types(base_type_objs());

            ko.utils.arrayForEach(self.rows(), clear_computed);

            self.rows(ko.utils.arrayMap(self.type_objs(), function(type) {
                return new TypeChartRow(type, self, self.base_chart().type_chart[type.index]);
            }));
        };

        self.reset_to_stored = function() {
            var base_chart = base_charts[self.stored_types.base];
            self.base_chart(base_chart);

            ko.utils.arrayForEach(self.type_objs(), clear_computed);

            self.type_objs(ko.utils.arrayMap(self.stored_types.types, function(type) {
                if (type.index in base_chart.type_chart && (type.name != base_chart.types[type.index] || type.multipliers.slice(0, base_chart.types.length).join(',') != base_chart.type_chart[type.index].join(','))) {
                    // This should be an existing type, but it's been edited
                    self.enable_edit_existing(true);
                }
                return new Type(type.index, type.name, type.real_index);
            }));

            self.selected_types(ko.utils.arrayMap(self.type_objs(), function(type) { return type; }));

            ko.utils.arrayForEach(self.rows(), clear_computed);

            self.rows(ko.utils.arrayMap(self.type_objs(), function(type) {
                return new TypeChartRow(type, self, self.stored_types.types[type.index].multipliers);
            }));
        };

        self.to_js = ko.computed(function() {
            return {
                base: self.base_chart().id,
                types: ko.utils.arrayMap(self.rows(), function(row) {
                    return {index: row.type.index, name: row.type.name(), multipliers: ko.utils.arrayMap(row.cells(), function(cell) {
                        return cell.multiplier();
                    }), real_index: row.type.real_index};
                })
            };
        });

        if (self.has_localstorage) {
            self.to_js.subscribe(function(js) {
                localStorage.setItem("custom_typechart", JSON.stringify(js));
            });
        }

        self.save_types = function() {
            self.stored_types = self.to_js();
        };

        self.add_type = function() {
            var type = new Type(self.type_objs().length, 'Custom', -1);
            self.type_objs.push(type);
            self.selected_types.push(type);
            ko.utils.arrayForEach(self.rows(), function(row) {
                row.cells.push(new TypeChartCell(row.type, type, self, 1));
            });
            self.rows.push(new TypeChartRow(type, self));
        };

        self.remove_type = function(type) {
            clear_computed(self.rows()[type.index]);
            self.rows().splice(type.index, 1);
            ko.utils.arrayForEach(self.rows(), function(row) {
                clear_computed(row.cells()[type.index]);
                row.cells.splice(type.index, 1);
            });
            clear_computed(self.type_objs()[type.index]);
            self.type_objs.splice(type.index, 1);
            for (var t = type.index; t < self.type_objs().length; t++) {
                self.type_objs()[t].index = t;
            }
            self.selected_types.remove(type);
            self.rows.valueHasMutated();
        };

        self.count_boundaries = ko.computed(function() {
            if (self.mode().id == 'summary' || self.mode().id == 'defense') {
                var highest_count = 0;
                var lowest_count = self.rows().length;
                var rows = self.rows();
                for (var i = 0; i < rows.length; i++) {
                    for (var j = 0; j < rows[i].cells().length; j++) {
                        var num = rows[i].cells()[j].value();
                        highest_count = Math.max(highest_count, num);
                        lowest_count = Math.min(lowest_count, num);
                    }
                }
                return {highest: highest_count, lowest: lowest_count};
            }
            else {
                return {highest: 0, lowest: 0}
            }
        });

        self.row_count_boundaries = ko.computed(function() {
            var highest_count = 0;
            var lowest_count = self.rows().length;
            for (var i = 0; i < self.rows().length; i++) {
                var num = self.rows()[i].summary_total();
                highest_count = Math.max(highest_count, num);
                lowest_count = Math.min(lowest_count, num);
            }
            return {highest: highest_count, lowest: lowest_count};
        });

        self.summary_rows = ko.computed(function() {
            return self.mode().get_summary_rows.call(self);
        });

        self.slide_add = function(element, index, data) {
            console.log("slide_add");
            $(element).hide().slideDown();
        };

        self.slide_remove = function(element, index, data) {
            console.log("slide_remove");
            $(element).slideUp(function() {
                $(this).remove();
            });
        };
    }

    var vm = new typeChartViewModel();

    ko.applyBindings(vm);

    $("#base_chart").change(function() {
        vm.set_base(vm.base_chart());
    });

    // Prevent clicking inside type chart cells to cycle multipliers from selecting text.
    $("#typechart td").attr('unselectable', 'on').css('user-select', 'none').on('selectstart', false);

    $("#typechart").on("mouseover", "td:not(.no-highlight)", function() {
        $("#typechart thead th.type-name[data-type-col=" + $(this).data("type-col") + "]").addClass("highlight-type");
        $(this).closest("tr").find("th.type-name").addClass("highlight-type");
        $(this).addClass("highlight-row");
    }).on("mouseout", "td:not(.no-highlight)", function() {
        $("#typechart thead th.type-name[data-type-col=" + $(this).data("type-col") + "]").removeClass("highlight-type");
        $(this).closest("tr").find("th.type-name").removeClass("highlight-type");
        $(this).removeClass("highlight-row");
    });

    $("#typechart").on("mouseover", "thead th.type-name", function() {
        $(this).addClass("highlight-row");
        $("#typechart td[data-type-col=" + $(this).data("type-col") + "]").addClass("highlight-row");
    }).on("mouseout", "thead th.type-name", function() {
        $(this).removeClass("highlight-row");
        $("#typechart td[data-type-col=" + $(this).data("type-col") + "]").removeClass("highlight-row");
    }).on("mouseover", "tbody th.type-name", function() {
        $(this).closest("tr").find("td, th").addClass("highlight-row");
    }).on("mouseout", "tbody th.type-name", function() {
        $(this).closest("tr").find("td, th").removeClass("highlight-row");
    });

    $("#typechart").on("click", "th.type-name input", function() { $(this).select(); });
});