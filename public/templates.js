require.register("views/page", function(exports, require, module){
    module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var locals_ = (locals || {}),asset = locals_.asset;
buf.push("<h1>" + (jade.escape((jade.interp = asset.getMeta('headline', '')) == null ? '' : jade.interp)) + " " + (jade.escape((jade.interp = asset.getMeta('title', '')) == null ? '' : jade.interp)) + "</h1>");;return buf.join("");
}
});
require.register("views/page404", function(exports, require, module){
    module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};

buf.push("<h1>Page not Found</h1>");;return buf.join("");
}
});