// WHY: B1 architecture check — circular deps deny (rule 28, code half).
// dependency-cruiser step in quality-gate-perlang runs when this file exists.
module.exports = {
	forbidden: [
		{
			name: "no-circular",
			severity: "error",
			comment: "rule 28: no circular dependencies",
			from: {},
			to: { circular: true },
		},
		{
			name: "no-orphans",
			severity: "warn",
			from: { orphan: true },
			to: {},
		},
	],
};
