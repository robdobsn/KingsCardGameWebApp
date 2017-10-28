# Creates a pseudo-random value generator. The seed must be an integer.
# Uses an optimized version of the Park-Miller PRNG.
# http://www.firstpr.com.au/dsp/rand31/

class PseudoRandom

  constructor: (seed) ->
    if isNaN(seed) or seed == null or seed == 0
      seed = @getRandomSeed()
    @seed = seed % 2147483647
    if @seed <= 0
      @seed += 2147483646

  # Returns a pseudo-random value between 1 and 2^32 - 2.
  next: () ->
    return @seed = @seed * 16807 % 2147483647

  # Returns a pseudo-random floating point number in range [0, 1).
  nextFloat: () ->
    # We know that result of next() will be 1 to 2147483646 (inclusive).
    return (@next() - 1) / 2147483646

  @getRandomSeed: () ->
    return Math.floor(Math.random() * 2147483645) + 1

  @getMaxSeed: () ->
    return 2147483646

