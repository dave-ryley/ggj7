local players = {
	{
		playerStats = {

			name = "player/1_test_name",
			health = 100,
			maxHealth = 100,
			level = 0,
			attack = 5,

			dodgeChance = 5,
			defense = 5

		},

		currentAbilities = {

			"Basic Strike",
			"Leap Attack",
		}
	},
	{
		playerStats = {

			name = "player2_test_name",
			health = 100,
			maxHealth = 100,
			level = 0,
			attack = 4,

			dodgeChance = 1,
			defense = 6

		},

		currentAbilities = {
			"Ground Pound",
			"Rage",
		}
	}
}
return players
