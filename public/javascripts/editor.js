
// Argument Editor
jquery(function() {

  var $ = jquery;

  // Use browserify's require().
  window.require = window.browserify.require;

  // Argumenta modules.
  var Objects = require('/lib/argumenta/objects');
  var Argument = Objects.Argument;
  var Proposition = Objects.Proposition;

  // Restore requirejs.
  window.require = requirejs;

  // Jquery object containing the argument editor element.
  var element = $('.new-argument');

  // Argument instance reflecting the current state.
  var argument;

  init();

  /**
   * Inits the element.
   */

  function init() {
    initButtons();
    initTextAreas();
  }

  /**
   * Inits the element's text areas.
   */

  function initTextAreas() {

    // Input Bindings
    element.on('input', 'textarea', function(event) {
      updateArgument();
    });

    // Autosize
    element.find('textarea').autosize();

    // Character counters
    element.find('.title textarea').charCount({ allowed: Argument.MAX_TITLE_LENGTH });
    element.find('.premise textarea').charCount({ allowed: Proposition.MAX_PROPOSITION_LENGTH });
    element.find('.conclusion textarea').charCount({ allowed: Proposition.MAX_PROPOSITION_LENGTH });
  }

  /**
   * Inits the element's buttons.
   */

  function initButtons() {

    // Add Premise
    element.on('click', '.addPremise', function(event) {
      var listItem = $(event.target).closest('.premise');
      var newItem = listItem.clone();
      clearPremises( newItem );
      listItem.after( newItem );

      var premises = element.find('.premise');
      labelPremises( premises );

      updateArgument();
      event.preventDefault();
    });

    // Remove Premise
    element.on('click', '.removePremise', function(event) {
      var listItem = $(event.target).closest('.premise');
      var siblings = listItem.siblings('.premise');

      if (siblings.length == 0) {
        clearPremises( listItem );
      }
      else {
        listItem.remove();
      }

      var remaining = element.find('.premise');
      labelPremises( remaining );

      updateArgument();
      event.preventDefault();
    });
  }

  /**
   * Updates argument to reflect the element's state.
   */

  function updateArgument() {
    data = argumentData();
    argument = new Argument(data.title, data.premises, data.conclusion);
    updateRepo(argument.repo());
    updateSha1(argument.sha1());
  }

  /**
   * Gets argument data from the element's input fields.
   */

  function argumentData() {
    var title = element.find('.title textarea').val();
    var premises = element.find('.premise textarea').map(function(){ return $(this).val() });
    var conclusion = element.find('.conclusion textarea').val();
    return { title: title, premises: premises, conclusion: conclusion };
  }

  /**
   * Updates the displayed repo name.
   */

  function updateRepo( repo ) {
    element.find('.repo').text( repo );
  }

  /**
   * Updates the displayed sha1.
   */

  function updateSha1( hex ) {
    element.find('.sha1').text( hex ).attr( 'title', argument.objectRecord() );
  }

  /**
   * Updates the label for each given premise.
   */

  function labelPremises(premises) {
    premises.each(function(index, el) {
      $(el).find('label').text("Premise " + (index+1));
    });
  }

  /**
   * Clears the state of each given premise.
   */

  function clearPremises(premises) {
    premises.find('.counter').remove();
    premises.find('textarea[name="premises"]')
      .val('')
      .attr('placeholder', '')
      .removeAttr('style')
      .autosize()
      .charCount({ allowed: Proposition.MAX_PROPOSITION_LENGTH });
  }

});
