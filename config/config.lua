Config = Config or {}

Config.Knockout = Config.Knockout or {} --Namespace Declation
Config.Knockout.Enabled = true --Bool:  Enables/Disables the knockout script
Config.Knockout.Duration = 5500 --Integer:  MS How long the knockout lasts for
Config.Knockout.HealthAmount = 155 --Integer:  100-200 At what health level will they be knocked out 100 is 0 and 200 is full
Config.Knockout.RegenInterval = 450 --Integer:  MS Time between health regenerations
Config.Knockout.Regeneration = 2 --Integer:  How much health to give each RegenInterval