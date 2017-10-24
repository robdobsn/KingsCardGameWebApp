// Generated by CoffeeScript 1.10.0
var PseudoRandom;

PseudoRandom = (function() {
  function PseudoRandom(seed) {
    if (isNaN(seed) || seed === null || seed === 0) {
      seed = this.getRandomSeed();
    }
    this.seed = seed % 2147483647;
    if (this.seed <= 0) {
      this.seed += 2147483646;
    }
  }

  PseudoRandom.prototype.getRandomSeed = function() {
    return Math.floor(Math.random() * 2147483645) + 1;
  };

  PseudoRandom.prototype.getMaxSeed = function() {
    return 2147483646;
  };

  PseudoRandom.prototype.next = function() {
    return this.seed = this.seed * 16807 % 2147483647;
  };

  PseudoRandom.prototype.nextFloat = function() {
    return (this.next() - 1) / 2147483646;
  };

  return PseudoRandom;

})();

//# sourceMappingURL=PseudoRandom.js.map