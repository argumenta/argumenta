(function () {

  // Draws stars on a given canvas.
  var drawStars = function (canvas) {
    var context = canvas.getContext('2d');
    var h = canvas.height = $(canvas).height();
    var w = canvas.width = $(canvas).width();

    var density = 0.0025;
    var N = w * h * density;
    var alpha, x, y;
    for (var i = 0; i < N; i++) {
      x = Math.floor(Math.random() * w);
      y = Math.floor(Math.random() * h);
      alpha = Math.random();
      context.fillStyle = 'rgba(255, 255, 255, ' + alpha + ' )';
      context.fillRect(x, y, 2, 2);
    }
  };

  // Shows the join modal.
  var showJoin = function() {
    $('.modal-background, .join-modal').fadeIn(300);
    return false;
  };

  // Shows the login modal.
  var showLogin = function() {
    $('.modal-background, .login-modal').fadeIn(300);
    return false;
  };

  // Hides all modals and background.
  var hideModals = function() {
    $('.modal-background, .join-modal, .login-modal').fadeOut(300);
  };

  // Initializes all modals.
  var initModals = function() {
    $('.show-join, .nav-join').click(showJoin);
    $('.nav-login').click(showLogin);
    $('.modal-background').click(hideModals);
    hideModals();
  };

  // Initializes the intro panel.
  var initIntro = function () {
    $('canvas.stars').each(function (index, element) {
      drawStars(element);
    });

    $('.learn-more').click(function (element) {
      $('.intro-panel').slideToggle(200);
    });

    $('.intro-panel').hide();
  };

  // Let's do this!
  initIntro();
  initModals();

})();
