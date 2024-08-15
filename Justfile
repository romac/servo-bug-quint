# Show help
help:
  @just --list

# Verify the given spec
verify SPEC:
  quint verify {{SPEC}} --main MC4 --invariant queuedTaskRuns

# Verify the broken spec
verify-broken:
  @just verify Broken.qnt

# Verify the fixed spec
verify-fixed:
  @just verify Fixed.qnt
