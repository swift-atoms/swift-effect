public import Hash

extension Effect::Effect.Outcome: Hash::Hash.`Protocol`
where Value: Hash::Hash.`Protocol` & ~Copyable, Failure: Hash::Hash.`Protocol` {}
