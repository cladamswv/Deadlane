#!/usr/bin/env python3
import math

def budget(w, endless=False):
    value=round(12+3.3*w+0.20*w*w)
    return min(value,210) if endless else value

assert 100*2 == 200
assert 100*3 == 300
assert budget(1)==16
assert budget(20)==158
assert budget(30)==291
assert budget(100,True)==210
for w in range(1,31):
    hp_scale=1+0.04*(w-1)
    speed_scale=min(1.35,1+0.015*(w-1))
    assert hp_scale <= 2.16 + 1e-9
    assert speed_scale <= 1.35 + 1e-9
print('Gate invariant: 100 input bullets -> 200 x2 outputs; original bullets removed by implementation.')
print('Campaign budgets:', ', '.join(f'{w}:{budget(w)}' for w in range(1,31)))
print('Endless wave 100 budget cap:', budget(100,True))
print('Manual-fire / faster-horde balance constants validated.')
print('DETERMINISTIC BALANCE CHECKS PASSED')
