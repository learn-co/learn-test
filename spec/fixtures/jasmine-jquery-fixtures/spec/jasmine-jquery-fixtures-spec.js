'use-strict';

describe('Using a local HTML fixture with jQuery', function() {
  beforeEach(function() {
    loadFixtures('index.html');
  });

  it('can use jQuery against a local fixture', function() {
    expect($('h1').text()).toBe('Hello World');
  });
});