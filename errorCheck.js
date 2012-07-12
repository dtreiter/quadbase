var QB = (function (my) {
  my.assert_equal = function(expected, actual, message) {
	if(expected!=actual) {
      throw new Error(message);
    }
  };
    
  
  my.assert_not_equal = function(expected, actual, message) {
	if(expected==actual) {
      throw new Error(message);
    }
  };


  my.assert_in_range = function(value, lower, upper, message) {
    if(value<lower||value>upper) {
      throw new Error(message);
    }
  };
  
  
  my.assert_not_in_range = function(value, lower, upper, message) {
    if(value>lower&&value<upper) {
      throw new Error(message);
    }
  };
  
return my;
}(QB || {}));