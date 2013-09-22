(function ($) {

  var Audience = function(element) {
    var self = this;
    self.counter = 0;
    self.$element = $(element);
    self.$element.on('mouseover', function() {
      self.update();
    });
  };

  var PHRASES =
  Audience.prototype.phrases = [
    'Truth seekers',
    'Skeptical minds',
    'Ethical enthusiasts',
    'Citizen scientists',
    'Scientific journalists',
    'Conspiracy theoreticians',
    'Ontological anarchists',
    'Singularity futurists',
    'Psychedelic researchers',
    'Experimental philosophers',
    'Friendly debunkers',
    'Post-political pirates',
    'Magical logicians',
    'Idea lovers'
  ];

  Audience.prototype.adjectives = PHRASES.map(
    function(phrase) {
      return phrase.split(/ /)[0];
    }
  );

  Audience.prototype.nouns = PHRASES.map(
    function(phrase) {
      return phrase.split(/ /)[1];
    }
  );

  Audience.prototype.start = function() {
    var self = this;
    self.update();
    self.run();
  };

  Audience.prototype.run = function() {
    var self = this;
    self.timeoutID = setTimeout(function() {
      self.update();
      self.run();
    }, 1000 * (10 + 5 * Math.log(Math.pow(self.counter, 2))));
  };

  Audience.prototype.stop = function() {
    var self = this;
    self.clearTimeout(self.timeoutID);
  };

  Audience.prototype.update = function() {
    var self = this;
    if (self.counter % 2 == 0) {
      self.randomize();
    }
    else {
      self.mix();
    }
    self.counter++;
  };

  Audience.prototype.randomize = function() {
    var self = this;
    self.setPhrase(self.randomPhrase());
  };

  Audience.prototype.mix = function() {
    var self = this;
    self.setPhrase(self.randomAdjective() + ' ' + self.randomNoun());
  };

  Audience.prototype.randomAdjective = function() {
    var self = this;
    return Audience.random(self.adjectives);
  };

  Audience.prototype.randomNoun = function() {
    var self = this;
    return Audience.random(self.nouns);
  };

  Audience.prototype.randomPhrase = function() {
    var self = this;
    return Audience.random(self.phrases);
  };

  Audience.random = function(arr) {
    return arr[
      Math.floor(Math.random() * arr.length)
    ];
  };

  Audience.prototype.setPhrase = function(phrase) {
    var self = this;
    self.$element.fadeOut(function() {
      self.$element.html('for ' + phrase);
      self.$element.fadeIn();
    });
  };

  var audienceElement = $('.audience');
  var audience = new Audience(audienceElement);
  audience.start();

})($);
