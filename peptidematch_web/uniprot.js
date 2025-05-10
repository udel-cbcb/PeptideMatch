var Prototype = {
    Version: "1.7",
    Browser: (function() {
        var B = navigator.userAgent;
        var A = Object.prototype.toString.call(window.opera) == "[object Opera]";
        return {
            IE: !! window.attachEvent && !A,
            Opera: A,
            WebKit: B.indexOf("AppleWebKit/") > -1,
            Gecko: B.indexOf("Gecko") > -1 && B.indexOf("KHTML") === -1,
            MobileSafari: /Apple.*Mobile/.test(B)
        }
    })(),
    BrowserFeatures: {
        XPath: !! document.evaluate,
        SelectorsAPI: !! document.querySelector,
        ElementExtensions: (function() {
            var A = window.Element || window.HTMLElement;
            return !!(A && A.prototype)
        })(),
        SpecificElementExtensions: (function() {
            if (typeof window.HTMLDivElement !== "undefined") {
                return true
            }
            var C = document.createElement("div"),
                B = document.createElement("form"),
                A = false;
            if (C.__proto__ && (C.__proto__ !== B.__proto__)) {
                A = true
            }
            C = B = null;
            return A
        })()
    },
    ScriptFragment: "<script[^>]*>([\\S\\s]*?)<\/script>",
    JSONFilter: /^\/\*-secure-([\s\S]*)\*\/\s*$/,
    emptyFunction: function() {},
    K: function(A) {
        return A
    }
};
if (Prototype.Browser.MobileSafari) {
    Prototype.BrowserFeatures.SpecificElementExtensions = false
}
var Abstract = {};
var Try = {
    these: function() {
        var C;
        for (var B = 0, D = arguments.length; B < D;
        B++) {
            var A = arguments[B];
            try {
                C = A();
                break
            } catch (E) {}
        }
        return C
    }
};
var Class = (function() {
    var D = (function() {
        for (var E in {
            toString: 1
        }) {
            if (E === "toString") {
                return false
            }
        }
        return true
    })();

    function A() {}
    function B() {
        var H = null,
            G = $A(arguments);
        if (Object.isFunction(G[0])) {
            H = G.shift()
        }
        function E() {
            this.initialize.apply(this, arguments)
        }
        Object.extend(E, Class.Methods);
        E.superclass = H;
        E.subclasses = [];
        if (H) {
            A.prototype = H.prototype;
            E.prototype = new A;
            H.subclasses.push(E)
        }
        for (var F = 0, I = G.length; F < I; F++) {
            E.addMethods(G[F])
        }
        if (!E.prototype.initialize) {
            E.prototype.initialize = Prototype.emptyFunction
        }
        E.prototype.constructor = E;
        return E
    }
    function C(K) {
        var G = this.superclass && this.superclass.prototype,
            F = Object.keys(K);
        if (D) {
            if (K.toString != Object.prototype.toString) {
                F.push("toString")
            }
            if (K.valueOf != Object.prototype.valueOf) {
                F.push("valueOf")
            }
        }
        for (var E = 0, H = F.length; E < H; E++) {
            var J = F[E],
                I = K[J];
            if (G && Object.isFunction(I) && I.argumentNames()[0] == "$super") {
                var L = I;
                I = (function(M) {
                    return function() {
                        return G[M].apply(this, arguments)
                    }
                })(J).wrap(L);
                I.valueOf = L.valueOf.bind(L);
                I.toString = L.toString.bind(L)
            }
            this.prototype[J] = I
        }
        return this
    }
    return {
        create: B,
        Methods: {
            addMethods: C
        }
    }
})();
(function() {
    var c = Object.prototype.toString,
        b = "Null",
        O = "Undefined",
        V = "Boolean",
        F = "Number",
        S = "String",
        h = "Object",
        T = "[object Function]",
        Y = "[object Boolean]",
        G = "[object Number]",
        L = "[object String]",
        H = "[object Array]",
        X = "[object Date]",
        I = window.JSON && typeof JSON.stringify === "function" && JSON.stringify(0) === "0" && typeof JSON.stringify(Prototype.K) === "undefined";

    function K(k) {
        switch (k) {
        case null:
            return b;
        case (void 0):
            return O
        }
        var j = typeof k;
        switch (j) {
        case "boolean":
            return V;
        case "number":
            return F;
        case "string":
            return S
        }
        return h
    }
    function Z(j, l) {
        for (var k in l) {
            j[k] = l[k]
        }
        return j
    }
    function g(j) {
        try {
            if (C(j)) {
                return "undefined"
            }
            if (j === null) {
                return "null"
            }
            return j.inspect ? j.inspect() : String(j)
        } catch (k) {
            if (k instanceof RangeError) {
                return "..."
            }
            throw k
        }
    }
    function d(j) {
        return f("", {
            "": j
        }, [])
    }
    function f(t, p, q) {
        var r = p[t],
            o = typeof r;
        if (K(r) === h && typeof r.toJSON === "function") {
            r = r.toJSON(t)
        }
        var l = c.call(r);
        switch (l) {
        case G:
        case Y:
        case L:
            r = r.valueOf()
        }
        switch (r) {
        case null:
            return "null";
        case true:
            return "true";
        case false:
            return "false"
        }
        o = typeof r;
        switch (o) {
        case "string":
            return r.inspect(true);
        case "number":
            return isFinite(r) ? String(r) : "null";
        case "object":
            for (var k = 0, j = q.length; k < j; k++) {
                if (q[k] === r) {
                    throw new TypeError()
                }
            }
            q.push(r);
            var n = [];
            if (l === H) {
                for (var k = 0, j = r.length; k < j; k++) {
                    var m = f(k, r, q);
                    n.push(typeof m === "undefined" ? "null" : m)
                }
                n = "[" + n.join(",") + "]"
            } else {
                var u = Object.keys(r);
                for (var k = 0, j = u.length; k < j; k++) {
                    var t = u[k],
                        m = f(t, r, q);
                    if (typeof m !== "undefined") {
                        n.push(t.inspect(true) + ":" + m)
                    }
                }
                n = "{" + n.join(",") + "}"
            }
            q.pop();
            return n
        }
    }
    function W(j) {
        return JSON.stringify(j)
    }
    function J(j) {
        return $H(j).toQueryString()
    }
    function P(j) {
        return j && j.toHTML ? j.toHTML() : String.interpret(j)
    }
    function R(j) {
        if (K(j) !== h) {
            throw new TypeError()
        }
        var k = [];
        for (var l in j) {
            if (j.hasOwnProperty(l)) {
                k.push(l)
            }
        }
        return k
    }
    function D(j) {
        var k = [];
        for (var l in j) {
            k.push(j[l])
        }
        return k
    }
    function a(j) {
        return Z({}, j)
    }
    function U(j) {
        return !!(j && j.nodeType == 1)
    }
    function M(j) {
        return c.call(j) === H
    }
    var B = (typeof Array.isArray == "function") && Array.isArray([]) && !Array.isArray({});
    if (B) {
        M = Array.isArray
    }
    function E(j) {
        return j instanceof Hash
    }
    function A(j) {
        return c.call(j) === T
    }
    function N(j) {
        return c.call(j) === L
    }
    function Q(j) {
        return c.call(j) === G
    }
    function e(j) {
        return c.call(j) === X
    }
    function C(j) {
        return typeof j === "undefined"
    }
    Z(Object, {
        extend: Z,
        inspect: g,
        toJSON: I ? W : d,
        toQueryString: J,
        toHTML: P,
        keys: Object.keys || R,
        values: D,
        clone: a,
        isElement: U,
        isArray: M,
        isHash: E,
        isFunction: A,
        isString: N,
        isNumber: Q,
        isDate: e,
        isUndefined: C
    })
})();
Object.extend(Function.prototype, (function() {
    var K = Array.prototype.slice;

    function D(O, L) {
        var N = O.length,
            M = L.length;
        while (M--) {
            O[N + M] = L[M]
        }
        return O
    }
    function I(M, L) {
        M = K.call(M, 0);
        return D(M, L)
    }
    function G() {
        var L = this.toString().match(/^[\s\(]*function[^(]*\(([^)]*)\)/)[1].replace(/\/\/.*?[\r\n]|\/\*(?:.|[\r\n])*?\*\//g, "").replace(/\s+/g, "").split(",");
        return L.length == 1 && !L[0] ? [] : L
    }
    function H(N) {
        if (arguments.length < 2 && Object.isUndefined(arguments[0])) {
            return this
        }
        var L = this,
            M = K.call(arguments, 1);
        return function() {
            var O = I(M, arguments);
            return L.apply(N, O)
        }
    }
    function F(N) {
        var L = this,
            M = K.call(arguments, 1);
        return function(P) {
            var O = D([P || window.event], M);
            return L.apply(N, O)
        }
    }
    function J() {
        if (!arguments.length) {
            return this
        }
        var L = this,
            M = K.call(arguments, 0);
        return function() {
            var N = I(M, arguments);
            return L.apply(this, N)
        }
    }
    function E(N) {
        var L = this,
            M = K.call(arguments, 1);
        N = N * 1000;
        return window.setTimeout(function() {
            return L.apply(L, M)
        }, N)
    }
    function A() {
        var L = D([0.01], arguments);
        return this.delay.apply(this, L)
    }
    function C(M) {
        var L = this;
        return function() {
            var N = D([L.bind(this)], arguments);
            return M.apply(this, N)
        }
    }
    function B() {
        if (this._methodized) {
            return this._methodized
        }
        var L = this;
        return this._methodized = function() {
            var M = D([this], arguments);
            return L.apply(null, M)
        }
    }
    return {
        argumentNames: G,
        bind: H,
        bindAsEventListener: F,
        curry: J,
        delay: E,
        defer: A,
        wrap: C,
        methodize: B
    }
})());
(function(C) {
    function B() {
        return this.getUTCFullYear() + "-" + (this.getUTCMonth() + 1).toPaddedString(2) + "-" + this.getUTCDate().toPaddedString(2) + "T" + this.getUTCHours().toPaddedString(2) + ":" + this.getUTCMinutes().toPaddedString(2) + ":" + this.getUTCSeconds().toPaddedString(2) + "Z"
    }
    function A() {
        return this.toISOString()
    }
    if (!C.toISOString) {
        C.toISOString = B
    }
    if (!C.toJSON) {
        C.toJSON = A
    }
})(Date.prototype);
RegExp.prototype.match = RegExp.prototype.test;
RegExp.escape = function(A) {
    return String(A).replace(/([.*+?^=!:${}()|[\]\/\\])/g, "\\$1")
};
var PeriodicalExecuter = Class.create({
    initialize: function(B, A) {
        this.callback = B;
        this.frequency = A;
        this.currentlyExecuting = false;
        this.registerCallback()
    },
    registerCallback: function() {
        this.timer = setInterval(this.onTimerEvent.bind(this), this.frequency * 1000)
    },
    execute: function() {
        this.callback(this)
    },
    stop: function() {
        if (!this.timer) {
            return
        }
        clearInterval(this.timer);
        this.timer = null
    },
    onTimerEvent: function() {
        if (!this.currentlyExecuting) {
            try {
                this.currentlyExecuting = true;
                this.execute();
                this.currentlyExecuting = false
            } catch (A) {
                this.currentlyExecuting = false;
                throw A
            }
        }
    }
});
Object.extend(String, {
    interpret: function(A) {
        return A == null ? "" : String(A)
    },
    specialChar: {
        "\b": "\\b",
        "\t": "\\t",
        "\n": "\\n",
        "\f": "\\f",
        "\r": "\\r",
        "\\": "\\\\"
    }
});
Object.extend(String.prototype, (function() {
    var NATIVE_JSON_PARSE_SUPPORT = window.JSON && typeof JSON.parse === "function" && JSON.parse('{"test": true}').test;

    function prepareReplacement(replacement) {
        if (Object.isFunction(replacement)) {
            return replacement
        }
        var template = new Template(replacement);
        return function(match) {
            return template.evaluate(match)
        }
    }
    function gsub(pattern, replacement) {
        var result = "",
            source = this,
            match;
        replacement = prepareReplacement(replacement);
        if (Object.isString(pattern)) {
            pattern = RegExp.escape(pattern)
        }
        if (!(pattern.length || pattern.source)) {
            replacement = replacement("");
            return replacement + source.split("").join(replacement) + replacement
        }
        while (source.length > 0) {
            if (match = source.match(pattern)) {
                result += source.slice(0, match.index);
                result += String.interpret(replacement(match));
                source = source.slice(match.index + match[0].length)
            } else {
                result += source, source = ""
            }
        }
        return result
    }
    function sub(pattern, replacement, count) {
        replacement = prepareReplacement(replacement);
        count = Object.isUndefined(count) ? 1 : count;
        return this.gsub(pattern, function(match) {
            if (--count < 0) {
                return match[0]
            }
            return replacement(match)
        })
    }
    function scan(pattern, iterator) {
        this.gsub(pattern, iterator);
        return String(this)
    }
    function truncate(length, truncation) {
        length = length || 30;
        truncation = Object.isUndefined(truncation) ? "..." : truncation;
        return this.length > length ? this.slice(0, length - truncation.length) + truncation : String(this)
    }
    function strip() {
        return this.replace(/^\s+/, "").replace(/\s+$/, "")
    }
    function stripTags() {
        return this.replace(/<\w+(\s+("[^"]*"|'[^']*'|[^>])+)?>|<\/\w+>/gi, "")
    }
    function stripScripts() {
        return this.replace(new RegExp(Prototype.ScriptFragment, "img"), "")
    }
    function extractScripts() {
        var matchAll = new RegExp(Prototype.ScriptFragment, "img"),
            matchOne = new RegExp(Prototype.ScriptFragment, "im");
        return (this.match(matchAll) || []).map(function(scriptTag) {
            return (scriptTag.match(matchOne) || ["", ""])[1]
        })
    }
    function evalScripts() {
        return this.extractScripts().map(function(script) {
            return eval(script)
        })
    }
    function escapeHTML() {
        return this.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    }
    function unescapeHTML() {
        return this.stripTags().replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&amp;/g, "&")
    }
    function toQueryParams(separator) {
        var match = this.strip().match(/([^?#]*)(#.*)?$/);
        if (!match) {
            return {}
        }
        return match[1].split(separator || "&").inject({}, function(hash, pair) {
            if ((pair = pair.split("="))[0]) {
                var key = decodeURIComponent(pair.shift()),
                    value = pair.length > 1 ? pair.join("=") : pair[0];
                if (value != undefined) {
                    value = decodeURIComponent(value)
                }
                if (key in hash) {
                    if (!Object.isArray(hash[key])) {
                        hash[key] = [hash[key]]
                    }
                    hash[key].push(value)
                } else {
                    hash[key] = value
                }
            }
            return hash
        })
    }
    function toArray() {
        return this.split("")
    }
    function succ() {
        return this.slice(0, this.length - 1) + String.fromCharCode(this.charCodeAt(this.length - 1) + 1)
    }
    function times(count) {
        return count < 1 ? "" : new Array(count + 1).join(this)
    }
    function camelize() {
        return this.replace(/-+(.)?/g, function(match, chr) {
            return chr ? chr.toUpperCase() : ""
        })
    }
    function capitalize() {
        return this.charAt(0).toUpperCase() + this.substring(1).toLowerCase()
    }
    function underscore() {
        return this.replace(/::/g, "/").replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2").replace(/([a-z\d])([A-Z])/g, "$1_$2").replace(/-/g, "_").toLowerCase()
    }
    function dasherize() {
        return this.replace(/_/g, "-")
    }
    function inspect(useDoubleQuotes) {
        var escapedString = this.replace(/[\x00-\x1f\\]/g, function(character) {
            if (character in String.specialChar) {
                return String.specialChar[character]
            }
            return "\\u00" + character.charCodeAt().toPaddedString(2, 16)
        });
        if (useDoubleQuotes) {
            return '"' + escapedString.replace(/"/g, '\\"') + '"'
        }
        return "'" + escapedString.replace(/'/g, "\\'") + "'"
    }
    function unfilterJSON(filter) {
        return this.replace(filter || Prototype.JSONFilter, "$1")
    }
    function isJSON() {
        var str = this;
        if (str.blank()) {
            return false
        }
        str = str.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, "@");
        str = str.replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, "]");
        str = str.replace(/(?:^|:|,)(?:\s*\[)+/g, "");
        return (/^[\],:{}\s]*$/).test(str)
    }
    function evalJSON(sanitize) {
        var json = this.unfilterJSON(),
            cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;
        if (cx.test(json)) {
            json = json.replace(cx, function(a) {
                return "\\u" + ("0000" + a.charCodeAt(0).toString(16)).slice(-4)
            })
        }
        try {
            if (!sanitize || json.isJSON()) {
                return eval("(" + json + ")")
            }
        } catch (e) {}
        throw new SyntaxError("Badly formed JSON string: " + this.inspect())
    }
    function parseJSON() {
        var json = this.unfilterJSON();
        return JSON.parse(json)
    }
    function include(pattern) {
        return this.indexOf(pattern) > -1
    }
    function startsWith(pattern) {
        return this.lastIndexOf(pattern, 0) === 0
    }
    function endsWith(pattern) {
        var d = this.length - pattern.length;
        return d >= 0 && this.indexOf(pattern, d) === d
    }
    function empty() {
        return this == ""
    }
    function blank() {
        return /^\s*$/.test(this)
    }
    function interpolate(object, pattern) {
        return new Template(this, pattern).evaluate(object)
    }
    return {
        gsub: gsub,
        sub: sub,
        scan: scan,
        truncate: truncate,
        strip: String.prototype.trim || strip,
        stripTags: stripTags,
        stripScripts: stripScripts,
        extractScripts: extractScripts,
        evalScripts: evalScripts,
        escapeHTML: escapeHTML,
        unescapeHTML: unescapeHTML,
        toQueryParams: toQueryParams,
        parseQuery: toQueryParams,
        toArray: toArray,
        succ: succ,
        times: times,
        camelize: camelize,
        capitalize: capitalize,
        underscore: underscore,
        dasherize: dasherize,
        inspect: inspect,
        unfilterJSON: unfilterJSON,
        isJSON: isJSON,
        evalJSON: NATIVE_JSON_PARSE_SUPPORT ? parseJSON : evalJSON,
        include: include,
        startsWith: startsWith,
        endsWith: endsWith,
        empty: empty,
        blank: blank,
        interpolate: interpolate
    }
})());
var Template = Class.create({
    initialize: function(A, B) {
        this.template = A.toString();
        this.pattern = B || Template.Pattern
    },
    evaluate: function(A) {
        if (A && Object.isFunction(A.toTemplateReplacements)) {
            A = A.toTemplateReplacements()
        }
        return this.template.gsub(this.pattern, function(D) {
            if (A == null) {
                return (D[1] + "")
            }
            var F = D[1] || "";
            if (F == "\\") {
                return D[2]
            }
            var B = A,
                G = D[3],
                E = /^([^.[]+|\[((?:.*?[^\\])?)\])(\.|\[|$)/;
            D = E.exec(G);
            if (D == null) {
                return F
            }
            while (D != null) {
                var C = D[1].startsWith("[") ? D[2].replace(/\\\\]/g, "]") : D[1];
                B = B[C];
                if (null == B || "" == D[3]) {
                    break
                }
                G = G.substring("[" == D[3] ? D[1].length : D[0].length);
                D = E.exec(G)
            }
            return F + String.interpret(B)
        })
    }
});
Template.Pattern = /(^|.|\r|\n)(#\{(.*?)\})/;
var $break = {};
var Enumerable = (function() {
    function C(Y, X) {
        var W = 0;
        try {
            this._each(function(a) {
                Y.call(X, a, W++)
            })
        } catch (Z) {
            if (Z != $break) {
                throw Z
            }
        }
        return this
    }
    function R(Z, Y, X) {
        var W = -Z,
            a = [],
            b = this.toArray();
        if (Z < 1) {
            return b
        }
        while ((W += Z) < b.length) {
            a.push(b.slice(W, W + Z))
        }
        return a.collect(Y, X)
    }
    function B(Y, X) {
        Y = Y || Prototype.K;
        var W = true;
        this.each(function(a, Z) {
            W = W && !! Y.call(X, a, Z);
            if (!W) {
                throw $break
            }
        });
        return W
    }
    function I(Y, X) {
        Y = Y || Prototype.K;
        var W = false;
        this.each(function(a, Z) {
            if (W = !! Y.call(X, a, Z)) {
                throw $break
            }
        });
        return W
    }
    function J(Y, X) {
        Y = Y || Prototype.K;
        var W = [];
        this.each(function(a, Z) {
            W.push(Y.call(X, a, Z))
        });
        return W
    }
    function T(Y, X) {
        var W;
        this.each(function(a, Z) {
            if (Y.call(X, a, Z)) {
                W = a;
                throw $break
            }
        });
        return W
    }
    function H(Y, X) {
        var W = [];
        this.each(function(a, Z) {
            if (Y.call(X, a, Z)) {
                W.push(a)
            }
        });
        return W
    }
    function G(Z, Y, X) {
        Y = Y || Prototype.K;
        var W = [];
        if (Object.isString(Z)) {
            Z = new RegExp(RegExp.escape(Z))
        }
        this.each(function(b, a) {
            if (Z.match(b)) {
                W.push(Y.call(X, b, a))
            }
        });
        return W
    }
    function A(W) {
        if (Object.isFunction(this.indexOf)) {
            if (this.indexOf(W) != -1) {
                return true
            }
        }
        var X = false;
        this.each(function(Y) {
            if (Y == W) {
                X = true;
                throw $break
            }
        });
        return X
    }
    function Q(X, W) {
        W = Object.isUndefined(W) ? null : W;
        return this.eachSlice(X, function(Y) {
            while (Y.length < X) {
                Y.push(W)
            }
            return Y
        })
    }
    function L(W, Y, X) {
        this.each(function(a, Z) {
            W = Y.call(X, W, a, Z)
        });
        return W
    }
    function V(X) {
        var W = $A(arguments).slice(1);
        return this.map(function(Y) {
            return Y[X].apply(Y, W)
        })
    }
    function P(Y, X) {
        Y = Y || Prototype.K;
        var W;
        this.each(function(a, Z) {
            a = Y.call(X, a, Z);
            if (W == null || a >= W) {
                W = a
            }
        });
        return W
    }
    function N(Y, X) {
        Y = Y || Prototype.K;
        var W;
        this.each(function(a, Z) {
            a = Y.call(X, a, Z);
            if (W == null || a < W) {
                W = a
            }
        });
        return W
    }
    function E(Z, X) {
        Z = Z || Prototype.K;
        var Y = [],
            W = [];
        this.each(function(b, a) {
            (Z.call(X, b, a) ? Y : W).push(b)
        });
        return [Y, W]
    }
    function F(X) {
        var W = [];
        this.each(function(Y) {
            W.push(Y[X])
        });
        return W
    }
    function D(Y, X) {
        var W = [];
        this.each(function(a, Z) {
            if (!Y.call(X, a, Z)) {
                W.push(a)
            }
        });
        return W
    }
    function M(X, W) {
        return this.map(function(Z, Y) {
            return {
                value: Z,
                criteria: X.call(W, Z, Y)
            }
        }).sort(function(d, c) {
            var Z = d.criteria,
                Y = c.criteria;
            return Z < Y ? -1 : Z > Y ? 1 : 0
        }).pluck("value")
    }
    function O() {
        return this.map()
    }
    function S() {
        var X = Prototype.K,
            W = $A(arguments);
        if (Object.isFunction(W.last())) {
            X = W.pop()
        }
        var Y = [this].concat(W).map($A);
        return this.map(function(a, Z) {
            return X(Y.pluck(Z))
        })
    }
    function K() {
        return this.toArray().length
    }
    function U() {
        return "#<Enumerable:" + this.toArray().inspect() + ">"
    }
    return {
        each: C,
        eachSlice: R,
        all: B,
        every: B,
        any: I,
        some: I,
        collect: J,
        map: J,
        detect: T,
        findAll: H,
        select: H,
        filter: H,
        grep: G,
        include: A,
        member: A,
        inGroupsOf: Q,
        inject: L,
        invoke: V,
        max: P,
        min: N,
        partition: E,
        pluck: F,
        reject: D,
        sortBy: M,
        toArray: O,
        entries: O,
        zip: S,
        size: K,
        inspect: U,
        find: T
    }
})();

function $A(C) {
    if (!C) {
        return []
    }
    if ("toArray" in Object(C)) {
        return C.toArray()
    }
    var B = C.length || 0,
        A = new Array(B);
    while (B--) {
        A[B] = C[B]
    }
    return A
}
function $w(A) {
    if (!Object.isString(A)) {
        return []
    }
    A = A.strip();
    return A ? A.split(/\s+/) : []
}
Array.from = $A;
(function() {
    var R = Array.prototype,
        M = R.slice,
        O = R.forEach;

    function B(W, V) {
        for (var U = 0, X = this.length >>> 0; U < X; U++) {
            if (U in this) {
                W.call(V, this[U], U, this)
            }
        }
    }
    if (!O) {
        O = B
    }
    function L() {
        this.length = 0;
        return this
    }
    function D() {
        return this[0]
    }
    function G() {
        return this[this.length - 1]
    }
    function I() {
        return this.select(function(U) {
            return U != null
        })
    }
    function T() {
        return this.inject([], function(V, U) {
            if (Object.isArray(U)) {
                return V.concat(U.flatten())
            }
            V.push(U);
            return V
        })
    }
    function H() {
        var U = M.call(arguments, 0);
        return this.select(function(V) {
            return !U.include(V)
        })
    }
    function F(U) {
        return (U === false ? this.toArray() : this)._reverse()
    }
    function K(U) {
        return this.inject([], function(X, W, V) {
            if (0 == V || (U ? X.last() != W : !X.include(W))) {
                X.push(W)
            }
            return X
        })
    }
    function P(U) {
        return this.uniq().findAll(function(V) {
            return U.detect(function(W) {
                return V === W
            })
        })
    }
    function Q() {
        return M.call(this, 0)
    }
    function J() {
        return this.length
    }
    function S() {
        return "[" + this.map(Object.inspect).join(", ") + "]"
    }
    function A(W, U) {
        U || (U = 0);
        var V = this.length;
        if (U < 0) {
            U = V + U
        }
        for (; U < V; U++) {
            if (this[U] === W) {
                return U
            }
        }
        return -1
    }
    function N(V, U) {
        U = isNaN(U) ? this.length : (U < 0 ? this.length + U : U) + 1;
        var W = this.slice(0, U).reverse().indexOf(V);
        return (W < 0) ? W : U - W - 1
    }
    function C() {
        var Z = M.call(this, 0),
            X;
        for (var V = 0, W = arguments.length;
        V < W; V++) {
            X = arguments[V];
            if (Object.isArray(X) && !("callee" in X)) {
                for (var U = 0, Y = X.length;
                U < Y; U++) {
                    Z.push(X[U])
                }
            } else {
                Z.push(X)
            }
        }
        return Z
    }
    Object.extend(R, Enumerable);
    if (!R._reverse) {
        R._reverse = R.reverse
    }
    Object.extend(R, {
        _each: O,
        clear: L,
        first: D,
        last: G,
        compact: I,
        flatten: T,
        without: H,
        reverse: F,
        uniq: K,
        intersect: P,
        clone: Q,
        toArray: Q,
        size: J,
        inspect: S
    });
    var E = (function() {
        return [].concat(arguments)[0][0] !== 1
    })(1, 2);
    if (E) {
        R.concat = C
    }
    if (!R.indexOf) {
        R.indexOf = A
    }
    if (!R.lastIndexOf) {
        R.lastIndexOf = N
    }
})();

function $H(A) {
    return new Hash(A)
}
var Hash = Class.create(Enumerable, (function() {
    function E(P) {
        this._object = Object.isHash(P) ? P.toObject() : Object.clone(P)
    }
    function F(Q) {
        for (var P in this._object) {
            var R = this._object[P],
                S = [P, R];
            S.key = P;
            S.value = R;
            Q(S)
        }
    }
    function J(P, Q) {
        return this._object[P] = Q
    }
    function C(P) {
        if (this._object[P] !== Object.prototype[P]) {
            return this._object[P]
        }
    }
    function M(P) {
        var Q = this._object[P];
        delete this._object[P];
        return Q
    }
    function O() {
        return Object.clone(this._object)
    }
    function N() {
        return this.pluck("key")
    }
    function L() {
        return this.pluck("value")
    }
    function G(Q) {
        var P = this.detect(function(R) {
            return R.value === Q
        });
        return P && P.key
    }
    function I(P) {
        return this.clone().update(P)
    }
    function D(P) {
        return new Hash(P).inject(this, function(Q, R) {
            Q.set(R.key, R.value);
            return Q
        })
    }
    function B(P, Q) {
        if (Object.isUndefined(Q)) {
            return P
        }
        return P + "=" + encodeURIComponent(String.interpret(Q))
    }
    function A() {
        return this.inject([], function(T, W) {
            var S = encodeURIComponent(W.key),
                Q = W.value;
            if (Q && typeof Q == "object") {
                if (Object.isArray(Q)) {
                    var V = [];
                    for (var R = 0, P = Q.length, U;
                    R < P; R++) {
                        U = Q[R];
                        V.push(B(S, U))
                    }
                    return T.concat(V)
                }
            } else {
                T.push(B(S, Q))
            }
            return T
        }).join("&")
    }
    function K() {
        return "#<Hash:{" + this.map(function(P) {
            return P.map(Object.inspect).join(": ")
        }).join(", ") + "}>"
    }
    function H() {
        return new Hash(this)
    }
    return {
        initialize: E,
        _each: F,
        set: J,
        get: C,
        unset: M,
        toObject: O,
        toTemplateReplacements: O,
        keys: N,
        values: L,
        index: G,
        merge: I,
        update: D,
        toQueryString: A,
        inspect: K,
        toJSON: O,
        clone: H
    }
})());
Hash.from = $H;
Object.extend(Number.prototype, (function() {
    function D() {
        return this.toPaddedString(2, 16)
    }
    function B() {
        return this + 1
    }
    function H(J, I) {
        $R(0, this, true).each(J, I);
        return this
    }
    function G(K, J) {
        var I = this.toString(J || 10);
        return "0".times(K - I.length) + I
    }
    function A() {
        return Math.abs(this)
    }
    function C() {
        return Math.round(this)
    }
    function E() {
        return Math.ceil(this)
    }
    function F() {
        return Math.floor(this)
    }
    return {
        toColorPart: D,
        succ: B,
        times: H,
        toPaddedString: G,
        abs: A,
        round: C,
        ceil: E,
        floor: F
    }
})());

function $R(C, A, B) {
    return new ObjectRange(C, A, B)
}
var ObjectRange = Class.create(Enumerable, (function() {
    function B(F, D, E) {
        this.start = F;
        this.end = D;
        this.exclusive = E
    }
    function C(D) {
        var E = this.start;
        while (this.include(E)) {
            D(E);
            E = E.succ()
        }
    }
    function A(D) {
        if (D < this.start) {
            return false
        }
        if (this.exclusive) {
            return D < this.end
        }
        return D <= this.end
    }
    return {
        initialize: B,
        _each: C,
        include: A
    }
})());
var Ajax = {
    getTransport: function() {
        return Try.these(function() {
            return new XMLHttpRequest()
        }, function() {
            return new ActiveXObject("Msxml2.XMLHTTP")
        }, function() {
            return new ActiveXObject("Microsoft.XMLHTTP")
        }) || false
    },
    activeRequestCount: 0
};
Ajax.Responders = {
    responders: [],
    _each: function(A) {
        this.responders._each(A)
    },
    register: function(A) {
        if (!this.include(A)) {
            this.responders.push(A)
        }
    },
    unregister: function(A) {
        this.responders = this.responders.without(A)
    },
    dispatch: function(D, B, C, A) {
        this.each(function(E) {
            if (Object.isFunction(E[D])) {
                try {
                    E[D].apply(E, [B, C, A])
                } catch (F) {}
            }
        })
    }
};
Object.extend(Ajax.Responders, Enumerable);
Ajax.Responders.register({
    onCreate: function() {
        Ajax.activeRequestCount++
    },
    onComplete: function() {
        Ajax.activeRequestCount--
    }
});
Ajax.Base = Class.create({
    initialize: function(A) {
        this.options = {
            method: "post",
            asynchronous: true,
            contentType: "application/x-www-form-urlencoded",
            encoding: "UTF-8",
            parameters: "",
            evalJSON: true,
            evalJS: true
        };
        Object.extend(this.options, A || {});
        this.options.method = this.options.method.toLowerCase();
        if (Object.isHash(this.options.parameters)) {
            this.options.parameters = this.options.parameters.toObject()
        }
    }
});
Ajax.Request = Class.create(Ajax.Base, {
    _complete: false,
    initialize: function($super, B, A) {
        $super(A);
        this.transport = Ajax.getTransport();
        this.request(B)
    },
    request: function(B) {
        this.url = B;
        this.method = this.options.method;
        var D = Object.isString(this.options.parameters) ? this.options.parameters : Object.toQueryString(this.options.parameters);
        if (!["get", "post"].include(this.method)) {
            D += (D ? "&" : "") + "_method=" + this.method;
            this.method = "post"
        }
        if (D && this.method === "get") {
            this.url += (this.url.include("?") ? "&" : "?") + D
        }
        this.parameters = D.toQueryParams();
        try {
            var A = new Ajax.Response(this);
            if (this.options.onCreate) {
                this.options.onCreate(A)
            }
            Ajax.Responders.dispatch("onCreate", this, A);
            this.transport.open(this.method.toUpperCase(), this.url, this.options.asynchronous);
            if (this.options.asynchronous) {
                this.respondToReadyState.bind(this).defer(1)
            }
            this.transport.onreadystatechange = this.onStateChange.bind(this);
            this.setRequestHeaders();
            this.body = this.method == "post" ? (this.options.postBody || D) : null;
            this.transport.send(this.body);
            if (!this.options.asynchronous && this.transport.overrideMimeType) {
                this.onStateChange()
            }
        } catch (C) {
            this.dispatchException(C)
        }
    },
    onStateChange: function() {
        var A = this.transport.readyState;
        if (A > 1 && !((A == 4) && this._complete)) {
            this.respondToReadyState(this.transport.readyState)
        }
    },
    setRequestHeaders: function() {
        var E = {
            "X-Requested-With": "XMLHttpRequest",
            "X-Prototype-Version": Prototype.Version,
            Accept: "text/javascript, text/html, application/xml, text/xml, */*"
        };
        if (this.method == "post") {
            E["Content-type"] = this.options.contentType + (this.options.encoding ? "; charset=" + this.options.encoding : "");
            if (this.transport.overrideMimeType && (navigator.userAgent.match(/Gecko\/(\d{4})/) || [0, 2005])[1] < 2005) {
                E.Connection = "close"
            }
        }
        if (typeof this.options.requestHeaders == "object") {
            var C = this.options.requestHeaders;
            if (Object.isFunction(C.push)) {
                for (var B = 0, D = C.length; B < D; B += 2) {
                    E[C[B]] = C[B + 1]
                }
            } else {
                $H(C).each(function(F) {
                    E[F.key] = F.value
                })
            }
        }
        for (var A in E) {
            this.transport.setRequestHeader(A, E[A])
        }
    },
    success: function() {
        var A = this.getStatus();
        return !A || (A >= 200 && A < 300) || A == 304
    },
    getStatus: function() {
        try {
            if (this.transport.status === 1223) {
                return 204
            }
            return this.transport.status || 0
        } catch (A) {
            return 0
        }
    },
    respondToReadyState: function(A) {
        var C = Ajax.Request.Events[A],
            B = new Ajax.Response(this);
        if (C == "Complete") {
            try {
                this._complete = true;
                (this.options["on" + B.status] || this.options["on" + (this.success() ? "Success" : "Failure")] || Prototype.emptyFunction)(B, B.headerJSON)
            } catch (D) {
                this.dispatchException(D)
            }
            var E = B.getHeader("Content-type");
            if (this.options.evalJS == "force" || (this.options.evalJS && this.isSameOrigin() && E && E.match(/^\s*(text|application)\/(x-)?(java|ecma)script(;.*)?\s*$/i))) {
                this.evalResponse()
            }
        }
        try {
            (this.options["on" + C] || Prototype.emptyFunction)(B, B.headerJSON);
            Ajax.Responders.dispatch("on" + C, this, B, B.headerJSON)
        } catch (D) {
            this.dispatchException(D)
        }
        if (C == "Complete") {
            this.transport.onreadystatechange = Prototype.emptyFunction
        }
    },
    isSameOrigin: function() {
        var A = this.url.match(/^\s*https?:\/\/[^\/]*/);
        return !A || (A[0] == "#{protocol}//#{domain}#{port}".interpolate({
            protocol: location.protocol,
            domain: document.domain,
            port: location.port ? ":" + location.port : ""
        }))
    },
    getHeader: function(A) {
        try {
            return this.transport.getResponseHeader(A) || null
        } catch (B) {
            return null
        }
    },
    evalResponse: function() {
        try {
            return eval((this.transport.responseText || "").unfilterJSON())
        } catch (e) {
            this.dispatchException(e)
        }
    },
    dispatchException: function(A) {
        (this.options.onException || Prototype.emptyFunction)(this, A);
        Ajax.Responders.dispatch("onException", this, A)
    }
});
Ajax.Request.Events = ["Uninitialized", "Loading", "Loaded", "Interactive", "Complete"];
Ajax.Response = Class.create({
    initialize: function(C) {
        this.request = C;
        var D = this.transport = C.transport,
            A = this.readyState = D.readyState;
        if ((A > 2 && !Prototype.Browser.IE) || A == 4) {
            this.status = this.getStatus();
            this.statusText = this.getStatusText();
            this.responseText = String.interpret(D.responseText);
            this.headerJSON = this._getHeaderJSON()
        }
        if (A == 4) {
            var B = D.responseXML;
            this.responseXML = Object.isUndefined(B) ? null : B;
            this.responseJSON = this._getResponseJSON()
        }
    },
    status: 0,
    statusText: "",
    getStatus: Ajax.Request.prototype.getStatus,
    getStatusText: function() {
        try {
            return this.transport.statusText || ""
        } catch (A) {
            return ""
        }
    },
    getHeader: Ajax.Request.prototype.getHeader,
    getAllHeaders: function() {
        try {
            return this.getAllResponseHeaders()
        } catch (A) {
            return null
        }
    },
    getResponseHeader: function(A) {
        return this.transport.getResponseHeader(A)
    },
    getAllResponseHeaders: function() {
        return this.transport.getAllResponseHeaders()
    },
    _getHeaderJSON: function() {
        var A = this.getHeader("X-JSON");
        if (!A) {
            return null
        }
        A = decodeURIComponent(escape(A));
        try {
            return A.evalJSON(this.request.options.sanitizeJSON || !this.request.isSameOrigin())
        } catch (B) {
            this.request.dispatchException(B)
        }
    },
    _getResponseJSON: function() {
        var A = this.request.options;
        if (!A.evalJSON || (A.evalJSON != "force" && !(this.getHeader("Content-type") || "").include("application/json")) || this.responseText.blank()) {
            return null
        }
        try {
            return this.responseText.evalJSON(A.sanitizeJSON || !this.request.isSameOrigin())
        } catch (B) {
            this.request.dispatchException(B)
        }
    }
});
Ajax.Updater = Class.create(Ajax.Request, {
    initialize: function($super, A, C, B) {
        this.container = {
            success: (A.success || A),
            failure: (A.failure || (A.success ? null : A))
        };
        B = Object.clone(B);
        var D = B.onComplete;
        B.onComplete = (function(E, F) {
            this.updateContent(E.responseText);
            if (Object.isFunction(D)) {
                D(E, F)
            }
        }).bind(this);
        $super(C, B)
    },
    updateContent: function(D) {
        var C = this.container[this.success() ? "success" : "failure"],
            A = this.options;
        if (!A.evalScripts) {
            D = D.stripScripts()
        }
        if (C = $(C)) {
            if (A.insertion) {
                if (Object.isString(A.insertion)) {
                    var B = {};
                    B[A.insertion] = D;
                    C.insert(B)
                } else {
                    A.insertion(C, D)
                }
            } else {
                C.update(D)
            }
        }
    }
});
Ajax.PeriodicalUpdater = Class.create(Ajax.Base, {
    initialize: function($super, A, C, B) {
        $super(B);
        this.onComplete = this.options.onComplete;
        this.frequency = (this.options.frequency || 2);
        this.decay = (this.options.decay || 1);
        this.updater = {};
        this.container = A;
        this.url = C;
        this.start()
    },
    start: function() {
        this.options.onComplete = this.updateComplete.bind(this);
        this.onTimerEvent()
    },
    stop: function() {
        this.updater.options.onComplete = undefined;
        clearTimeout(this.timer);
        (this.onComplete || Prototype.emptyFunction).apply(this, arguments)
    },
    updateComplete: function(A) {
        if (this.options.decay) {
            this.decay = (A.responseText == this.lastText ? this.decay * this.options.decay : 1);
            this.lastText = A.responseText
        }
        this.timer = this.onTimerEvent.bind(this).delay(this.decay * this.frequency)
    },
    onTimerEvent: function() {
        this.updater = new Ajax.Updater(this.container, this.url, this.options)
    }
});

function $(B) {
    if (arguments.length > 1) {
        for (var A = 0, D = [], C = arguments.length; A < C;
        A++) {
            D.push($(arguments[A]))
        }
        return D
    }
    if (Object.isString(B)) {
        B = document.getElementById(B)
    }
    return Element.extend(B)
}
if (Prototype.BrowserFeatures.XPath) {
    document._getElementsByXPath = function(F, A) {
        var C = [];
        var E = document.evaluate(F, $(A) || document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
        for (var B = 0, D = E.snapshotLength; B < D; B++) {
            C.push(Element.extend(E.snapshotItem(B)))
        }
        return C
    }
}
if (!Node) {
    var Node = {}
}
if (!Node.ELEMENT_NODE) {
    Object.extend(Node, {
        ELEMENT_NODE: 1,
        ATTRIBUTE_NODE: 2,
        TEXT_NODE: 3,
        CDATA_SECTION_NODE: 4,
        ENTITY_REFERENCE_NODE: 5,
        ENTITY_NODE: 6,
        PROCESSING_INSTRUCTION_NODE: 7,
        COMMENT_NODE: 8,
        DOCUMENT_NODE: 9,
        DOCUMENT_TYPE_NODE: 10,
        DOCUMENT_FRAGMENT_NODE: 11,
        NOTATION_NODE: 12
    })
}(function(C) {
    function D(F, E) {
        if (F === "select") {
            return false
        }
        if ("type" in E) {
            return false
        }
        return true
    }
    var B = (function() {
        try {
            var E = document.createElement('<input name="x">');
            return E.tagName.toLowerCase() === "input" && E.name === "x"
        } catch (F) {
            return false
        }
    })();
    var A = C.Element;
    C.Element = function(G, F) {
        F = F || {};
        G = G.toLowerCase();
        var E = Element.cache;
        if (B && F.name) {
            G = "<" + G + ' name="' + F.name + '">';
            delete F.name;
            return Element.writeAttribute(document.createElement(G), F)
        }
        if (!E[G]) {
            E[G] = Element.extend(document.createElement(G))
        }
        var H = D(G, F) ? E[G].cloneNode(false) : document.createElement(G);
        return Element.writeAttribute(H, F)
    };
    Object.extend(C.Element, A || {});
    if (A) {
        C.Element.prototype = A.prototype
    }
})(this);
Element.idCounter = 1;
Element.cache = {};
Element._purgeElement = function(B) {
    var A = B._prototypeUID;
    if (A) {
        Element.stopObserving(B);
        B._prototypeUID = void 0;
        delete Element.Storage[A]
    }
};
Element.Methods = {
    visible: function(A) {
        return $(A).style.display != "none"
    },
    toggle: function(A) {
        A = $(A);
        Element[Element.visible(A) ? "hide" : "show"](A);
        return A
    },
    hide: function(A) {
        A = $(A);
        A.style.display = "none";
        return A
    },
    show: function(A) {
        A = $(A);
        A.style.display = "";
        return A
    },
    remove: function(A) {
        A = $(A);
        A.parentNode.removeChild(A);
        return A
    },
    update: (function() {
        var D = (function() {
            var G = document.createElement("select"),
                H = true;
            G.innerHTML = '<option value="test">test</option>';
            if (G.options && G.options[0]) {
                H = G.options[0].nodeName.toUpperCase() !== "OPTION"
            }
            G = null;
            return H
        })();
        var B = (function() {
            try {
                var G = document.createElement("table");
                if (G && G.tBodies) {
                    G.innerHTML = "<tbody><tr><td>test</td></tr></tbody>";
                    var I = typeof G.tBodies[0] == "undefined";
                    G = null;
                    return I
                }
            } catch (H) {
                return true
            }
        })();
        var A = (function() {
            try {
                var G = document.createElement("div");
                G.innerHTML = "<link>";
                var I = (G.childNodes.length === 0);
                G = null;
                return I
            } catch (H) {
                return true
            }
        })();
        var C = D || B || A;
        var F = (function() {
            var G = document.createElement("script"),
                I = false;
            try {
                G.appendChild(document.createTextNode(""));
                I = !G.firstChild || G.firstChild && G.firstChild.nodeType !== 3
            } catch (H) {
                I = true
            }
            G = null;
            return I
        })();

        function E(K, L) {
            K = $(K);
            var G = Element._purgeElement;
            var M = K.getElementsByTagName("*"),
                J = M.length;
            while (J--) {
                G(M[J])
            }
            if (L && L.toElement) {
                L = L.toElement()
            }
            if (Object.isElement(L)) {
                return K.update().insert(L)
            }
            L = Object.toHTML(L);
            var I = K.tagName.toUpperCase();
            if (I === "SCRIPT" && F) {
                K.text = L;
                return K
            }
            if (C) {
                if (I in Element._insertionTranslations.tags) {
                    while (K.firstChild) {
                        K.removeChild(K.firstChild)
                    }
                    Element._getContentFromAnonymousElement(I, L.stripScripts()).each(function(N) {
                        K.appendChild(N)
                    })
                } else {
                    if (A && Object.isString(L) && L.indexOf("<link") > -1) {
                        while (K.firstChild) {
                            K.removeChild(K.firstChild)
                        }
                        var H = Element._getContentFromAnonymousElement(I, L.stripScripts(), true);
                        H.each(function(N) {
                            K.appendChild(N)
                        })
                    } else {
                        K.innerHTML = L.stripScripts()
                    }
                }
            } else {
                K.innerHTML = L.stripScripts()
            }
            L.evalScripts.bind(L).defer();
            return K
        }
        return E
    })(),
    replace: function(B, C) {
        B = $(B);
        if (C && C.toElement) {
            C = C.toElement()
        } else {
            if (!Object.isElement(C)) {
                C = Object.toHTML(C);
                var A = B.ownerDocument.createRange();
                A.selectNode(B);
                C.evalScripts.bind(C).defer();
                C = A.createContextualFragment(C.stripScripts())
            }
        }
        B.parentNode.replaceChild(C, B);
        return B
    },
    insert: function(C, E) {
        C = $(C);
        if (Object.isString(E) || Object.isNumber(E) || Object.isElement(E) || (E && (E.toElement || E.toHTML))) {
            E = {
                bottom: E
            }
        }
        var D, F, B, G;
        for (var A in E) {
            D = E[A];
            A = A.toLowerCase();
            F = Element._insertionTranslations[A];
            if (D && D.toElement) {
                D = D.toElement()
            }
            if (Object.isElement(D)) {
                F(C, D);
                continue
            }
            D = Object.toHTML(D);
            B = ((A == "before" || A == "after") ? C.parentNode : C).tagName.toUpperCase();
            G = Element._getContentFromAnonymousElement(B, D.stripScripts());
            if (A == "top" || A == "after") {
                G.reverse()
            }
            G.each(F.curry(C));
            D.evalScripts.bind(D).defer()
        }
        return C
    },
    wrap: function(B, C, A) {
        B = $(B);
        if (Object.isElement(C)) {
            $(C).writeAttribute(A || {})
        } else {
            if (Object.isString(C)) {
                C = new Element(C, A)
            } else {
                C = new Element("div", C)
            }
        }
        if (B.parentNode) {
            B.parentNode.replaceChild(C, B)
        }
        C.appendChild(B);
        return C
    },
    inspect: function(B) {
        B = $(B);
        var A = "<" + B.tagName.toLowerCase();
        $H({
            id: "id",
            className: "class"
        }).each(function(F) {
            var E = F.first(),
                C = F.last(),
                D = (B[E] || "").toString();
            if (D) {
                A += " " + C + "=" + D.inspect(true)
            }
        });
        return A + ">"
    },
    recursivelyCollect: function(A, C, D) {
        A = $(A);
        D = D || -1;
        var B = [];
        while (A = A[C]) {
            if (A.nodeType == 1) {
                B.push(Element.extend(A))
            }
            if (B.length == D) {
                break
            }
        }
        return B
    },
    ancestors: function(A) {
        return Element.recursivelyCollect(A, "parentNode")
    },
    descendants: function(A) {
        return Element.select(A, "*")
    },
    firstDescendant: function(A) {
        A = $(A).firstChild;
        while (A && A.nodeType != 1) {
            A = A.nextSibling
        }
        return $(A)
    },
    immediateDescendants: function(B) {
        var A = [],
            C = $(B).firstChild;
        while (C) {
            if (C.nodeType === 1) {
                A.push(Element.extend(C))
            }
            C = C.nextSibling
        }
        return A
    },
    previousSiblings: function(A, B) {
        return Element.recursivelyCollect(A, "previousSibling")
    },
    nextSiblings: function(A) {
        return Element.recursivelyCollect(A, "nextSibling")
    },
    siblings: function(A) {
        A = $(A);
        return Element.previousSiblings(A).reverse().concat(Element.nextSiblings(A))
    },
    match: function(B, A) {
        B = $(B);
        if (Object.isString(A)) {
            return Prototype.Selector.match(B, A)
        }
        return A.match(B)
    },
    up: function(B, D, A) {
        B = $(B);
        if (arguments.length == 1) {
            return $(B.parentNode)
        }
        var C = Element.ancestors(B);
        return Object.isNumber(D) ? C[D] : Prototype.Selector.find(C, D, A)
    },
    down: function(B, C, A) {
        B = $(B);
        if (arguments.length == 1) {
            return Element.firstDescendant(B)
        }
        return Object.isNumber(C) ? Element.descendants(B)[C] : Element.select(B, C)[A || 0]
    },
    previous: function(B, C, A) {
        B = $(B);
        if (Object.isNumber(C)) {
            A = C, C = false
        }
        if (!Object.isNumber(A)) {
            A = 0
        }
        if (C) {
            return Prototype.Selector.find(B.previousSiblings(), C, A)
        } else {
            return B.recursivelyCollect("previousSibling", A + 1)[A]
        }
    },
    next: function(B, D, A) {
        B = $(B);
        if (Object.isNumber(D)) {
            A = D, D = false
        }
        if (!Object.isNumber(A)) {
            A = 0
        }
        if (D) {
            return Prototype.Selector.find(B.nextSiblings(), D, A)
        } else {
            var C = Object.isNumber(A) ? A + 1 : 1;
            return B.recursivelyCollect("nextSibling", A + 1)[A]
        }
    },
    select: function(A) {
        A = $(A);
        var B = Array.prototype.slice.call(arguments, 1).join(", ");
        return Prototype.Selector.select(B, A)
    },
    adjacent: function(A) {
        A = $(A);
        var B = Array.prototype.slice.call(arguments, 1).join(", ");
        return Prototype.Selector.select(B, A.parentNode).without(A)
    },
    identify: function(A) {
        A = $(A);
        var B = Element.readAttribute(A, "id");
        if (B) {
            return B
        }
        do {
            B = "anonymous_element_" + Element.idCounter++
        } while ($(B));
        Element.writeAttribute(A, "id", B);
        return B
    },
    readAttribute: function(C, A) {
        C = $(C);
        if (Prototype.Browser.IE) {
            var B = Element._attributeTranslations.read;
            if (B.values[A]) {
                return B.values[A](C, A)
            }
            if (B.names[A]) {
                A = B.names[A]
            }
            if (A.include(":")) {
                return (!C.attributes || !C.attributes[A]) ? null : C.attributes[A].value
            }
        }
        return C.getAttribute(A)
    },
    writeAttribute: function(E, C, F) {
        E = $(E);
        var B = {},
            D = Element._attributeTranslations.write;
        if (typeof C == "object") {
            B = C
        } else {
            B[C] = Object.isUndefined(F) ? true : F
        }
        for (var A in B) {
            C = D.names[A] || A;
            F = B[A];
            if (D.values[A]) {
                C = D.values[A](E, F)
            }
            if (F === false || F === null) {
                E.removeAttribute(C)
            } else {
                if (F === true) {
                    E.setAttribute(C, C)
                } else {
                    E.setAttribute(C, F)
                }
            }
        }
        return E
    },
    getHeight: function(A) {
        return Element.getDimensions(A).height
    },
    getWidth: function(A) {
        return Element.getDimensions(A).width
    },
    classNames: function(A) {
        return new Element.ClassNames(A)
    },
    hasClassName: function(A, B) {
        if (!(A = $(A))) {
            return
        }
        var C = A.className;
        return (C.length > 0 && (C == B || new RegExp("(^|\\s)" + B + "(\\s|$)").test(C)))
    },
    addClassName: function(A, B) {
        if (!(A = $(A))) {
            return
        }
        if (!Element.hasClassName(A, B)) {
            A.className += (A.className ? " " : "") + B
        }
        return A
    },
    removeClassName: function(A, B) {
        if (!(A = $(A))) {
            return
        }
        A.className = A.className.replace(new RegExp("(^|\\s+)" + B + "(\\s+|$)"), " ").strip();
        return A
    },
    toggleClassName: function(A, B) {
        if (!(A = $(A))) {
            return
        }
        return Element[Element.hasClassName(A, B) ? "removeClassName" : "addClassName"](A, B)
    },
    cleanWhitespace: function(B) {
        B = $(B);
        var C = B.firstChild;
        while (C) {
            var A = C.nextSibling;
            if (C.nodeType == 3 && !/\S/.test(C.nodeValue)) {
                B.removeChild(C)
            }
            C = A
        }
        return B
    },
    empty: function(A) {
        return $(A).innerHTML.blank()
    },
    descendantOf: function(B, A) {
        B = $(B), A = $(A);
        if (B.compareDocumentPosition) {
            return (B.compareDocumentPosition(A) & 8) === 8
        }
        if (A.contains) {
            return A.contains(B) && A !== B
        }
        while (B = B.parentNode) {
            if (B == A) {
                return true
            }
        }
        return false
    },
    scrollTo: function(A) {
        A = $(A);
        var B = Element.cumulativeOffset(A);
        window.scrollTo(B[0], B[1]);
        return A
    },
    getStyle: function(B, C) {
        B = $(B);
        C = C == "float" ? "cssFloat" : C.camelize();
        var D = B.style[C];
        if (!D || D == "auto") {
            var A = document.defaultView.getComputedStyle(B, null);
            D = A ? A[C] : null
        }
        if (C == "opacity") {
            return D ? parseFloat(D) : 1
        }
        return D == "auto" ? null : D
    },
    getOpacity: function(A) {
        return $(A).getStyle("opacity")
    },
    setStyle: function(B, C) {
        B = $(B);
        var E = B.style,
            A;
        if (Object.isString(C)) {
            B.style.cssText += ";" + C;
            return C.include("opacity") ? B.setOpacity(C.match(/opacity:\s*(\d?\.?\d*)/)[1]) : B
        }
        for (var D in C) {
            if (D == "opacity") {
                B.setOpacity(C[D])
            } else {
                E[(D == "float" || D == "cssFloat") ? (Object.isUndefined(E.styleFloat) ? "cssFloat" : "styleFloat") : D] = C[D]
            }
        }
        return B
    },
    setOpacity: function(A, B) {
        A = $(A);
        A.style.opacity = (B == 1 || B === "") ? "" : (B < 0.00001) ? 0 : B;
        return A
    },
    makePositioned: function(A) {
        A = $(A);
        var B = Element.getStyle(A, "position");
        if (B == "static" || !B) {
            A._madePositioned = true;
            A.style.position = "relative";
            if (Prototype.Browser.Opera) {
                A.style.top = 0;
                A.style.left = 0
            }
        }
        return A
    },
    undoPositioned: function(A) {
        A = $(A);
        if (A._madePositioned) {
            A._madePositioned = undefined;
            A.style.position = A.style.top = A.style.left = A.style.bottom = A.style.right = ""
        }
        return A
    },
    makeClipping: function(A) {
        A = $(A);
        if (A._overflow) {
            return A
        }
        A._overflow = Element.getStyle(A, "overflow") || "auto";
        if (A._overflow !== "hidden") {
            A.style.overflow = "hidden"
        }
        return A
    },
    undoClipping: function(A) {
        A = $(A);
        if (!A._overflow) {
            return A
        }
        A.style.overflow = A._overflow == "auto" ? "" : A._overflow;
        A._overflow = null;
        return A
    },
    clonePosition: function(B, D) {
        var A = Object.extend({
            setLeft: true,
            setTop: true,
            setWidth: true,
            setHeight: true,
            offsetTop: 0,
            offsetLeft: 0
        }, arguments[2] || {});
        D = $(D);
        var E = Element.viewportOffset(D),
            F = [0, 0],
            C = null;
        B = $(B);
        if (Element.getStyle(B, "position") == "absolute") {
            C = Element.getOffsetParent(B);
            F = Element.viewportOffset(C)
        }
        if (C == document.body) {
            F[0] -= document.body.offsetLeft;
            F[1] -= document.body.offsetTop
        }
        if (A.setLeft) {
            B.style.left = (E[0] - F[0] + A.offsetLeft) + "px"
        }
        if (A.setTop) {
            B.style.top = (E[1] - F[1] + A.offsetTop) + "px"
        }
        if (A.setWidth) {
            B.style.width = D.offsetWidth + "px"
        }
        if (A.setHeight) {
            B.style.height = D.offsetHeight + "px"
        }
        return B
    }
};
Object.extend(Element.Methods, {
    getElementsBySelector: Element.Methods.select,
    childElements: Element.Methods.immediateDescendants
});
Element._attributeTranslations = {
    write: {
        names: {
            className: "class",
            htmlFor: "for"
        },
        values: {}
    }
};
if (Prototype.Browser.Opera) {
    Element.Methods.getStyle = Element.Methods.getStyle.wrap(function(D, B, C) {
        switch (C) {
        case "height":
        case "width":
            if (!Element.visible(B)) {
                return null
            }
            var E = parseInt(D(B, C), 10);
            if (E !== B["offset" + C.capitalize()]) {
                return E + "px"
            }
            var A;
            if (C === "height") {
                A = ["border-top-width", "padding-top", "padding-bottom", "border-bottom-width"]
            } else {
                A = ["border-left-width", "padding-left", "padding-right", "border-right-width"]
            }
            return A.inject(E, function(F, G) {
                var H = D(B, G);
                return H === null ? F : F - parseInt(H, 10)
            }) + "px";
        default:
            return D(B, C)
        }
    });
    Element.Methods.readAttribute = Element.Methods.readAttribute.wrap(function(C, A, B) {
        if (B === "title") {
            return A.title
        }
        return C(A, B)
    })
} else {
    if (Prototype.Browser.IE) {
        Element.Methods.getStyle = function(A, B) {
            A = $(A);
            B = (B == "float" || B == "cssFloat") ? "styleFloat" : B.camelize();
            var C = A.style[B];
            if (!C && A.currentStyle) {
                C = A.currentStyle[B]
            }
            if (B == "opacity") {
                if (C = (A.getStyle("filter") || "").match(/alpha\(opacity=(.*)\)/)) {
                    if (C[1]) {
                        return parseFloat(C[1]) / 100
                    }
                }
                return 1
            }
            if (C == "auto") {
                if ((B == "width" || B == "height") && (A.getStyle("display") != "none")) {
                    return A["offset" + B.capitalize()] + "px"
                }
                return null
            }
            return C
        };
        Element.Methods.setOpacity = function(B, E) {
            function F(G) {
                return G.replace(/alpha\([^\)]*\)/gi, "")
            }
            B = $(B);
            var A = B.currentStyle;
            if ((A && !A.hasLayout) || (!A && B.style.zoom == "normal")) {
                B.style.zoom = 1
            }
            var D = B.getStyle("filter"),
                C = B.style;
            if (E == 1 || E === "") {
                (D = F(D)) ? C.filter = D : C.removeAttribute("filter");
                return B
            } else {
                if (E < 0.00001) {
                    E = 0
                }
            }
            C.filter = F(D) + "alpha(opacity=" + (E * 100) + ")";
            return B
        };
        Element._attributeTranslations = (function() {
            var B = "className",
                A = "for",
                C = document.createElement("div");
            C.setAttribute(B, "x");
            if (C.className !== "x") {
                C.setAttribute("class", "x");
                if (C.className === "x") {
                    B = "class"
                }
            }
            C = null;
            C = document.createElement("label");
            C.setAttribute(A, "x");
            if (C.htmlFor !== "x") {
                C.setAttribute("htmlFor", "x");
                if (C.htmlFor === "x") {
                    A = "htmlFor"
                }
            }
            C = null;
            return {
                read: {
                    names: {
                        "class": B,
                        className: B,
                        "for": A,
                        htmlFor: A
                    },
                    values: {
                        _getAttr: function(D, E) {
                            return D.getAttribute(E)
                        },
                        _getAttr2: function(D, E) {
                            return D.getAttribute(E, 2)
                        },
                        _getAttrNode: function(D, F) {
                            var E = D.getAttributeNode(F);
                            return E ? E.value : ""
                        },
                        _getEv: (function() {
                            var D = document.createElement("div"),
                                F;
                            D.onclick = Prototype.emptyFunction;
                            var E = D.getAttribute("onclick");
                            if (String(E).indexOf("{") > -1) {
                                F = function(G, H) {
                                    H = G.getAttribute(H);
                                    if (!H) {
                                        return null
                                    }
                                    H = H.toString();
                                    H = H.split("{")[1];
                                    H = H.split("}")[0];
                                    return H.strip()
                                }
                            } else {
                                if (E === "") {
                                    F = function(G, H) {
                                        H = G.getAttribute(H);
                                        if (!H) {
                                            return null
                                        }
                                        return H.strip()
                                    }
                                }
                            }
                            D = null;
                            return F
                        })(),
                        _flag: function(D, E) {
                            return $(D).hasAttribute(E) ? E : null
                        },
                        style: function(D) {
                            return D.style.cssText.toLowerCase()
                        },
                        title: function(D) {
                            return D.title
                        }
                    }
                }
            }
        })();
        Element._attributeTranslations.write = {
            names: Object.extend({
                cellpadding: "cellPadding",
                cellspacing: "cellSpacing"
            }, Element._attributeTranslations.read.names),
            values: {
                checked: function(A, B) {
                    A.checked = !! B
                },
                style: function(A, B) {
                    A.style.cssText = B ? B : ""
                }
            }
        };
        Element._attributeTranslations.has = {};
        $w("colSpan rowSpan vAlign dateTime accessKey tabIndex encType maxLength readOnly longDesc frameBorder").each(function(A) {
            Element._attributeTranslations.write.names[A.toLowerCase()] = A;
            Element._attributeTranslations.has[A.toLowerCase()] = A
        });
        (function(A) {
            Object.extend(A, {
                href: A._getAttr2,
                src: A._getAttr2,
                type: A._getAttr,
                action: A._getAttrNode,
                disabled: A._flag,
                checked: A._flag,
                readonly: A._flag,
                multiple: A._flag,
                onload: A._getEv,
                onunload: A._getEv,
                onclick: A._getEv,
                ondblclick: A._getEv,
                onmousedown: A._getEv,
                onmouseup: A._getEv,
                onmouseover: A._getEv,
                onmousemove: A._getEv,
                onmouseout: A._getEv,
                onfocus: A._getEv,
                onblur: A._getEv,
                onkeypress: A._getEv,
                onkeydown: A._getEv,
                onkeyup: A._getEv,
                onsubmit: A._getEv,
                onreset: A._getEv,
                onselect: A._getEv,
                onchange: A._getEv
            })
        })(Element._attributeTranslations.read.values);
        if (Prototype.BrowserFeatures.ElementExtensions) {
            (function() {
                function A(E) {
                    var B = E.getElementsByTagName("*"),
                        D = [];
                    for (var C = 0, F; F = B[C]; C++) {
                        if (F.tagName !== "!") {
                            D.push(F)
                        }
                    }
                    return D
                }
                Element.Methods.down = function(C, D, B) {
                    C = $(C);
                    if (arguments.length == 1) {
                        return C.firstDescendant()
                    }
                    return Object.isNumber(D) ? A(C)[D] : Element.select(C, D)[B || 0]
                }
            })()
        }
    } else {
        if (Prototype.Browser.Gecko && /rv:1\.8\.0/.test(navigator.userAgent)) {
            Element.Methods.setOpacity = function(A, B) {
                A = $(A);
                A.style.opacity = (B == 1) ? 0.999999 : (B === "") ? "" : (B < 0.00001) ? 0 : B;
                return A
            }
        } else {
            if (Prototype.Browser.WebKit) {
                Element.Methods.setOpacity = function(A, B) {
                    A = $(A);
                    A.style.opacity = (B == 1 || B === "") ? "" : (B < 0.00001) ? 0 : B;
                    if (B == 1) {
                        if (A.tagName.toUpperCase() == "IMG" && A.width) {
                            A.width++;
                            A.width--
                        } else {
                            try {
                                var D = document.createTextNode(" ");
                                A.appendChild(D);
                                A.removeChild(D)
                            } catch (C) {}
                        }
                    }
                    return A
                }
            }
        }
    }
}
if ("outerHTML" in document.documentElement) {
    Element.Methods.replace = function(C, E) {
        C = $(C);
        if (E && E.toElement) {
            E = E.toElement()
        }
        if (Object.isElement(E)) {
            C.parentNode.replaceChild(E, C);
            return C
        }
        E = Object.toHTML(E);
        var D = C.parentNode,
            B = D.tagName.toUpperCase();
        if (Element._insertionTranslations.tags[B]) {
            var F = C.next(),
                A = Element._getContentFromAnonymousElement(B, E.stripScripts());
            D.removeChild(C);
            if (F) {
                A.each(function(G) {
                    D.insertBefore(G, F)
                })
            } else {
                A.each(function(G) {
                    D.appendChild(G)
                })
            }
        } else {
            C.outerHTML = E.stripScripts()
        }
        E.evalScripts.bind(E).defer();
        return C
    }
}
Element._returnOffset = function(B, C) {
    var A = [B, C];
    A.left = B;
    A.top = C;
    return A
};
Element._getContentFromAnonymousElement = function(E, D, F) {
    var G = new Element("div"),
        C = Element._insertionTranslations.tags[E];
    var A = false;
    if (C) {
        A = true
    } else {
        if (F) {
            A = true;
            C = ["", "", 0]
        }
    }
    if (A) {
        G.innerHTML = "&nbsp;" + C[0] + D + C[1];
        G.removeChild(G.firstChild);
        for (var B = C[2]; B--;) {
            G = G.firstChild
        }
    } else {
        G.innerHTML = D
    }
    return $A(G.childNodes)
};
Element._insertionTranslations = {
    before: function(A, B) {
        A.parentNode.insertBefore(B, A)
    },
    top: function(A, B) {
        A.insertBefore(B, A.firstChild)
    },
    bottom: function(A, B) {
        A.appendChild(B)
    },
    after: function(A, B) {
        A.parentNode.insertBefore(B, A.nextSibling)
    },
    tags: {
        TABLE: ["<table>", "</table>", 1],
        TBODY: ["<table><tbody>", "</tbody></table>", 2],
        TR: ["<table><tbody><tr>", "</tr></tbody></table>", 3],
        TD: ["<table><tbody><tr><td>", "</td></tr></tbody></table>", 4],
        SELECT: ["<select>", "</select>", 1]
    }
};
(function() {
    var A = Element._insertionTranslations.tags;
    Object.extend(A, {
        THEAD: A.TBODY,
        TFOOT: A.TBODY,
        TH: A.TD
    })
})();
Element.Methods.Simulated = {
    hasAttribute: function(A, C) {
        C = Element._attributeTranslations.has[C] || C;
        var B = $(A).getAttributeNode(C);
        return !!(B && B.specified)
    }
};
Element.Methods.ByTag = {};
Object.extend(Element, Element.Methods);
(function(A) {
    if (!Prototype.BrowserFeatures.ElementExtensions && A.__proto__) {
        window.HTMLElement = {};
        window.HTMLElement.prototype = A.__proto__;
        Prototype.BrowserFeatures.ElementExtensions = true
    }
    A = null
})(document.createElement("div"));
Element.extend = (function() {
    function C(G) {
        if (typeof window.Element != "undefined") {
            var I = window.Element.prototype;
            if (I) {
                var K = "_" + (Math.random() + "").slice(2),
                    H = document.createElement(G);
                I[K] = "x";
                var J = (H[K] !== "x");
                delete I[K];
                H = null;
                return J
            }
        }
        return false
    }
    function B(H, G) {
        for (var J in G) {
            var I = G[J];
            if (Object.isFunction(I) && !(J in H)) {
                H[J] = I.methodize()
            }
        }
    }
    var D = C("object");
    if (Prototype.BrowserFeatures.SpecificElementExtensions) {
        if (D) {
            return function(H) {
                if (H && typeof H._extendedByPrototype == "undefined") {
                    var G = H.tagName;
                    if (G && (/^(?:object|applet|embed)$/i.test(G))) {
                        B(H, Element.Methods);
                        B(H, Element.Methods.Simulated);
                        B(H, Element.Methods.ByTag[G.toUpperCase()])
                    }
                }
                return H
            }
        }
        return Prototype.K
    }
    var A = {},
        E = Element.Methods.ByTag;
    var F = Object.extend(function(I) {
        if (!I || typeof I._extendedByPrototype != "undefined" || I.nodeType != 1 || I == window) {
            return I
        }
        var G = Object.clone(A),
            H = I.tagName.toUpperCase();
        if (E[H]) {
            Object.extend(G, E[H])
        }
        B(I, G);
        I._extendedByPrototype = Prototype.emptyFunction;
        return I
    }, {
        refresh: function() {
            if (!Prototype.BrowserFeatures.ElementExtensions) {
                Object.extend(A, Element.Methods);
                Object.extend(A, Element.Methods.Simulated)
            }
        }
    });
    F.refresh();
    return F
})();
if (document.documentElement.hasAttribute) {
    Element.hasAttribute = function(A, B) {
        return A.hasAttribute(B)
    }
} else {
    Element.hasAttribute = Element.Methods.Simulated.hasAttribute
}
Element.addMethods = function(C) {
    var J = Prototype.BrowserFeatures,
        D = Element.Methods.ByTag;
    if (!C) {
        Object.extend(Form, Form.Methods);
        Object.extend(Form.Element, Form.Element.Methods);
        Object.extend(Element.Methods.ByTag, {
            FORM: Object.clone(Form.Methods),
            INPUT: Object.clone(Form.Element.Methods),
            SELECT: Object.clone(Form.Element.Methods),
            TEXTAREA: Object.clone(Form.Element.Methods),
            BUTTON: Object.clone(Form.Element.Methods)
        })
    }
    if (arguments.length == 2) {
        var B = C;
        C = arguments[1]
    }
    if (!B) {
        Object.extend(Element.Methods, C || {})
    } else {
        if (Object.isArray(B)) {
            B.each(H)
        } else {
            H(B)
        }
    }
    function H(F) {
        F = F.toUpperCase();
        if (!Element.Methods.ByTag[F]) {
            Element.Methods.ByTag[F] = {}
        }
        Object.extend(Element.Methods.ByTag[F], C)
    }
    function A(M, L, F) {
        F = F || false;
        for (var O in M) {
            var N = M[O];
            if (!Object.isFunction(N)) {
                continue
            }
            if (!F || !(O in L)) {
                L[O] = N.methodize()
            }
        }
    }
    function E(N) {
        var F;
        var M = {
            OPTGROUP: "OptGroup",
            TEXTAREA: "TextArea",
            P: "Paragraph",
            FIELDSET: "FieldSet",
            UL: "UList",
            OL: "OList",
            DL: "DList",
            DIR: "Directory",
            H1: "Heading",
            H2: "Heading",
            H3: "Heading",
            H4: "Heading",
            H5: "Heading",
            H6: "Heading",
            Q: "Quote",
            INS: "Mod",
            DEL: "Mod",
            A: "Anchor",
            IMG: "Image",
            CAPTION: "TableCaption",
            COL: "TableCol",
            COLGROUP: "TableCol",
            THEAD: "TableSection",
            TFOOT: "TableSection",
            TBODY: "TableSection",
            TR: "TableRow",
            TH: "TableCell",
            TD: "TableCell",
            FRAMESET: "FrameSet",
            IFRAME: "IFrame"
        };
        if (M[N]) {
            F = "HTML" + M[N] + "Element"
        }
        if (window[F]) {
            return window[F]
        }
        F = "HTML" + N + "Element";
        if (window[F]) {
            return window[F]
        }
        F = "HTML" + N.capitalize() + "Element";
        if (window[F]) {
            return window[F]
        }
        var L = document.createElement(N),
            O = L.__proto__ || L.constructor.prototype;
        L = null;
        return O
    }
    var I = window.HTMLElement ? HTMLElement.prototype : Element.prototype;
    if (J.ElementExtensions) {
        A(Element.Methods, I);
        A(Element.Methods.Simulated, I, true)
    }
    if (J.SpecificElementExtensions) {
        for (var K in Element.Methods.ByTag) {
            var G = E(K);
            if (Object.isUndefined(G)) {
                continue
            }
            A(D[K], G.prototype)
        }
    }
    Object.extend(Element, Element.Methods);
    delete Element.ByTag;
    if (Element.extend.refresh) {
        Element.extend.refresh()
    }
    Element.cache = {}
};
document.viewport = {
    getDimensions: function() {
        return {
            width: this.getWidth(),
            height: this.getHeight()
        }
    },
    getScrollOffsets: function() {
        return Element._returnOffset(window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft, window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop)
    }
};
(function(C) {
    var H = Prototype.Browser,
        F = document,
        D, E = {};

    function A() {
        if (H.WebKit && !F.evaluate) {
            return document
        }
        if (H.Opera && window.parseFloat(window.opera.version()) < 9.5) {
            return document.body
        }
        return document.documentElement
    }
    function G(B) {
        if (!D) {
            D = A()
        }
        E[B] = "client" + B;
        C["get" + B] = function() {
            return D[E[B]]
        };
        return C["get" + B]()
    }
    C.getWidth = G.curry("Width");
    C.getHeight = G.curry("Height")
})(document.viewport);
Element.Storage = {
    UID: 1
};
Element.addMethods({
    getStorage: function(B) {
        if (!(B = $(B))) {
            return
        }
        var A;
        if (B === window) {
            A = 0
        } else {
            if (typeof B._prototypeUID === "undefined") {
                B._prototypeUID = Element.Storage.UID++
            }
            A = B._prototypeUID
        }
        if (!Element.Storage[A]) {
            Element.Storage[A] = $H()
        }
        return Element.Storage[A]
    },
    store: function(B, A, C) {
        if (!(B = $(B))) {
            return
        }
        if (arguments.length === 2) {
            Element.getStorage(B).update(A)
        } else {
            Element.getStorage(B).set(A, C)
        }
        return B
    },
    retrieve: function(C, B, A) {
        if (!(C = $(C))) {
            return
        }
        var E = Element.getStorage(C),
            D = E.get(B);
        if (Object.isUndefined(D)) {
            E.set(B, A);
            D = A
        }
        return D
    },
    clone: function(C, A) {
        if (!(C = $(C))) {
            return
        }
        var E = C.cloneNode(A);
        E._prototypeUID = void 0;
        if (A) {
            var D = Element.select(E, "*"),
                B = D.length;
            while (B--) {
                D[B]._prototypeUID = void 0
            }
        }
        return Element.extend(E)
    },
    purge: function(C) {
        if (!(C = $(C))) {
            return
        }
        var A = Element._purgeElement;
        A(C);
        var D = C.getElementsByTagName("*"),
            B = D.length;
        while (B--) {
            A(D[B])
        }
        return null
    }
});
(function() {
    function H(V) {
        var U = V.match(/^(\d+)%?$/i);
        if (!U) {
            return null
        }
        return (Number(U[1]) / 100)
    }
    function O(f, g, V) {
        var Y = null;
        if (Object.isElement(f)) {
            Y = f;
            f = Y.getStyle(g)
        }
        if (f === null) {
            return null
        }
        if ((/^(?:-)?\d+(\.\d+)?(px)?$/i).test(f)) {
            return window.parseFloat(f)
        }
        var a = f.include("%"),
            W = (V === document.viewport);
        if (/\d/.test(f) && Y && Y.runtimeStyle && !(a && W)) {
            var U = Y.style.left,
                e = Y.runtimeStyle.left;
            Y.runtimeStyle.left = Y.currentStyle.left;
            Y.style.left = f || 0;
            f = Y.style.pixelLeft;
            Y.style.left = U;
            Y.runtimeStyle.left = e;
            return f
        }
        if (Y && a) {
            V = V || Y.parentNode;
            var X = H(f);
            var b = null;
            var Z = Y.getStyle("position");
            var d = g.include("left") || g.include("right") || g.include("width");
            var c = g.include("top") || g.include("bottom") || g.include("height");
            if (V === document.viewport) {
                if (d) {
                    b = document.viewport.getWidth()
                } else {
                    if (c) {
                        b = document.viewport.getHeight()
                    }
                }
            } else {
                if (d) {
                    b = $(V).measure("width")
                } else {
                    if (c) {
                        b = $(V).measure("height")
                    }
                }
            }
            return (b === null) ? 0 : b * X
        }
        return 0
    }
    function G(U) {
        if (Object.isString(U) && U.endsWith("px")) {
            return U
        }
        return U + "px"
    }
    function J(V) {
        var U = V;
        while (V && V.parentNode) {
            var W = V.getStyle("display");
            if (W === "none") {
                return false
            }
            V = $(V.parentNode)
        }
        return true
    }
    var D = Prototype.K;
    if ("currentStyle" in document.documentElement) {
        D = function(U) {
            if (!U.currentStyle.hasLayout) {
                U.style.zoom = 1
            }
            return U
        }
    }
    function F(U) {
        if (U.include("border")) {
            U = U + "-width"
        }
        return U.camelize()
    }
    Element.Layout = Class.create(Hash, {
        initialize: function($super, V, U) {
            $super();
            this.element = $(V);
            Element.Layout.PROPERTIES.each(function(W) {
                this._set(W, null)
            }, this);
            if (U) {
                this._preComputing = true;
                this._begin();
                Element.Layout.PROPERTIES.each(this._compute, this);
                this._end();
                this._preComputing = false
            }
        },
        _set: function(V, U) {
            return Hash.prototype.set.call(this, V, U)
        },
        set: function(V, U) {
            throw "Properties of Element.Layout are read-only."
        },
        get: function($super, V) {
            var U = $super(V);
            return U === null ? this._compute(V) : U
        },
        _begin: function() {
            if (this._prepared) {
                return
            }
            var Y = this.element;
            if (J(Y)) {
                this._prepared = true;
                return
            }
            var a = {
                position: Y.style.position || "",
                width: Y.style.width || "",
                visibility: Y.style.visibility || "",
                display: Y.style.display || ""
            };
            Y.store("prototype_original_styles", a);
            var b = Y.getStyle("position"),
                U = Y.getStyle("width");
            if (U === "0px" || U === null) {
                Y.style.display = "block";
                U = Y.getStyle("width")
            }
            var V = (b === "fixed") ? document.viewport : Y.parentNode;
            Y.setStyle({
                position: "absolute",
                visibility: "hidden",
                display: "block"
            });
            var W = Y.getStyle("width");
            var X;
            if (U && (W === U)) {
                X = O(Y, "width", V)
            } else {
                if (b === "absolute" || b === "fixed") {
                    X = O(Y, "width", V)
                } else {
                    var c = Y.parentNode,
                        Z = $(c).getLayout();
                    X = Z.get("width") - this.get("margin-left") - this.get("border-left") - this.get("padding-left") - this.get("padding-right") - this.get("border-right") - this.get("margin-right")
                }
            }
            Y.setStyle({
                width: X + "px"
            });
            this._prepared = true
        },
        _end: function() {
            var V = this.element;
            var U = V.retrieve("prototype_original_styles");
            V.store("prototype_original_styles", null);
            V.setStyle(U);
            this._prepared = false
        },
        _compute: function(V) {
            var U = Element.Layout.COMPUTATIONS;
            if (!(V in U)) {
                throw "Property not found."
            }
            return this._set(V, U[V].call(this, this.element))
        },
        toObject: function() {
            var U = $A(arguments);
            var V = (U.length === 0) ? Element.Layout.PROPERTIES : U.join(" ").split(" ");
            var W = {};
            V.each(function(X) {
                if (!Element.Layout.PROPERTIES.include(X)) {
                    return
                }
                var Y = this.get(X);
                if (Y != null) {
                    W[X] = Y
                }
            }, this);
            return W
        },
        toHash: function() {
            var U = this.toObject.apply(this, arguments);
            return new Hash(U)
        },
        toCSS: function() {
            var U = $A(arguments);
            var W = (U.length === 0) ? Element.Layout.PROPERTIES : U.join(" ").split(" ");
            var V = {};
            W.each(function(X) {
                if (!Element.Layout.PROPERTIES.include(X)) {
                    return
                }
                if (Element.Layout.COMPOSITE_PROPERTIES.include(X)) {
                    return
                }
                var Y = this.get(X);
                if (Y != null) {
                    V[F(X)] = Y + "px"
                }
            }, this);
            return V
        },
        inspect: function() {
            return "#<Element.Layout>"
        }
    });
    Object.extend(Element.Layout, {
        PROPERTIES: $w("height width top left right bottom border-left border-right border-top border-bottom padding-left padding-right padding-top padding-bottom margin-top margin-bottom margin-left margin-right padding-box-width padding-box-height border-box-width border-box-height margin-box-width margin-box-height"),
        COMPOSITE_PROPERTIES: $w("padding-box-width padding-box-height margin-box-width margin-box-height border-box-width border-box-height"),
        COMPUTATIONS: {
            height: function(W) {
                if (!this._preComputing) {
                    this._begin()
                }
                var U = this.get("border-box-height");
                if (U <= 0) {
                    if (!this._preComputing) {
                        this._end()
                    }
                    return 0
                }
                var X = this.get("border-top"),
                    V = this.get("border-bottom");
                var Z = this.get("padding-top"),
                    Y = this.get("padding-bottom");
                if (!this._preComputing) {
                    this._end()
                }
                return U - X - V - Z - Y
            },
            width: function(W) {
                if (!this._preComputing) {
                    this._begin()
                }
                var V = this.get("border-box-width");
                if (V <= 0) {
                    if (!this._preComputing) {
                        this._end()
                    }
                    return 0
                }
                var Z = this.get("border-left"),
                    U = this.get("border-right");
                var X = this.get("padding-left"),
                    Y = this.get("padding-right");
                if (!this._preComputing) {
                    this._end()
                }
                return V - Z - U - X - Y
            },
            "padding-box-height": function(V) {
                var U = this.get("height"),
                    X = this.get("padding-top"),
                    W = this.get("padding-bottom");
                return U + X + W
            },
            "padding-box-width": function(U) {
                var V = this.get("width"),
                    W = this.get("padding-left"),
                    X = this.get("padding-right");
                return V + W + X
            },
            "border-box-height": function(V) {
                if (!this._preComputing) {
                    this._begin()
                }
                var U = V.offsetHeight;
                if (!this._preComputing) {
                    this._end()
                }
                return U
            },
            "border-box-width": function(U) {
                if (!this._preComputing) {
                    this._begin()
                }
                var V = U.offsetWidth;
                if (!this._preComputing) {
                    this._end()
                }
                return V
            },
            "margin-box-height": function(V) {
                var U = this.get("border-box-height"),
                    W = this.get("margin-top"),
                    X = this.get("margin-bottom");
                if (U <= 0) {
                    return 0
                }
                return U + W + X
            },
            "margin-box-width": function(W) {
                var V = this.get("border-box-width"),
                    X = this.get("margin-left"),
                    U = this.get("margin-right");
                if (V <= 0) {
                    return 0
                }
                return V + X + U
            },
            top: function(U) {
                var V = U.positionedOffset();
                return V.top
            },
            bottom: function(U) {
                var X = U.positionedOffset(),
                    V = U.getOffsetParent(),
                    W = V.measure("height");
                var Y = this.get("border-box-height");
                return W - Y - X.top
            },
            left: function(U) {
                var V = U.positionedOffset();
                return V.left
            },
            right: function(W) {
                var Y = W.positionedOffset(),
                    X = W.getOffsetParent(),
                    U = X.measure("width");
                var V = this.get("border-box-width");
                return U - V - Y.left
            },
            "padding-top": function(U) {
                return O(U, "paddingTop")
            },
            "padding-bottom": function(U) {
                return O(U, "paddingBottom")
            },
            "padding-left": function(U) {
                return O(U, "paddingLeft")
            },
            "padding-right": function(U) {
                return O(U, "paddingRight")
            },
            "border-top": function(U) {
                return O(U, "borderTopWidth")
            },
            "border-bottom": function(U) {
                return O(U, "borderBottomWidth")
            },
            "border-left": function(U) {
                return O(U, "borderLeftWidth")
            },
            "border-right": function(U) {
                return O(U, "borderRightWidth")
            },
            "margin-top": function(U) {
                return O(U, "marginTop")
            },
            "margin-bottom": function(U) {
                return O(U, "marginBottom")
            },
            "margin-left": function(U) {
                return O(U, "marginLeft")
            },
            "margin-right": function(U) {
                return O(U, "marginRight")
            }
        }
    });
    if ("getBoundingClientRect" in document.documentElement) {
        Object.extend(Element.Layout.COMPUTATIONS, {
            right: function(V) {
                var W = D(V.getOffsetParent());
                var X = V.getBoundingClientRect(),
                    U = W.getBoundingClientRect();
                return (U.right - X.right).round()
            },
            bottom: function(V) {
                var W = D(V.getOffsetParent());
                var X = V.getBoundingClientRect(),
                    U = W.getBoundingClientRect();
                return (U.bottom - X.bottom).round()
            }
        })
    }
    Element.Offset = Class.create({
        initialize: function(V, U) {
            this.left = V.round();
            this.top = U.round();
            this[0] = this.left;
            this[1] = this.top
        },
        relativeTo: function(U) {
            return new Element.Offset(this.left - U.left, this.top - U.top)
        },
        inspect: function() {
            return "#<Element.Offset left: #{left} top: #{top}>".interpolate(this)
        },
        toString: function() {
            return "[#{left}, #{top}]".interpolate(this)
        },
        toArray: function() {
            return [this.left, this.top]
        }
    });

    function R(V, U) {
        return new Element.Layout(V, U)
    }
    function B(U, V) {
        return $(U).getLayout().get(V)
    }
    function N(V) {
        V = $(V);
        var Z = Element.getStyle(V, "display");
        if (Z && Z !== "none") {
            return {
                width: V.offsetWidth,
                height: V.offsetHeight
            }
        }
        var W = V.style;
        var U = {
            visibility: W.visibility,
            position: W.position,
            display: W.display
        };
        var Y = {
            visibility: "hidden",
            display: "block"
        };
        if (U.position !== "fixed") {
            Y.position = "absolute"
        }
        Element.setStyle(V, Y);
        var X = {
            width: V.offsetWidth,
            height: V.offsetHeight
        };
        Element.setStyle(V, U);
        return X
    }
    function L(U) {
        U = $(U);
        if (E(U) || C(U) || M(U) || K(U)) {
            return $(document.body)
        }
        var V = (Element.getStyle(U, "display") === "inline");
        if (!V && U.offsetParent) {
            return $(U.offsetParent)
        }
        while ((U = U.parentNode) && U !== document.body) {
            if (Element.getStyle(U, "position") !== "static") {
                return K(U) ? $(document.body) : $(U)
            }
        }
        return $(document.body)
    }
    function T(V) {
        V = $(V);
        var U = 0,
            W = 0;
        if (V.parentNode) {
            do {
                U += V.offsetTop || 0;
                W += V.offsetLeft || 0;
                V = V.offsetParent
            } while (V)
        }
        return new Element.Offset(W, U)
    }
    function P(V) {
        V = $(V);
        var W = V.getLayout();
        var U = 0,
            Y = 0;
        do {
            U += V.offsetTop || 0;
            Y += V.offsetLeft || 0;
            V = V.offsetParent;
            if (V) {
                if (M(V)) {
                    break
                }
                var X = Element.getStyle(V, "position");
                if (X !== "static") {
                    break
                }
            }
        } while (V);
        Y -= W.get("margin-top");
        U -= W.get("margin-left");
        return new Element.Offset(Y, U)
    }
    function A(V) {
        var U = 0,
            W = 0;
        do {
            U += V.scrollTop || 0;
            W += V.scrollLeft || 0;
            V = V.parentNode
        } while (V);
        return new Element.Offset(W, U)
    }
    function S(Y) {
        V = $(V);
        var U = 0,
            X = 0,
            W = document.body;
        var V = Y;
        do {
            U += V.offsetTop || 0;
            X += V.offsetLeft || 0;
            if (V.offsetParent == W && Element.getStyle(V, "position") == "absolute") {
                break
            }
        } while (V = V.offsetParent);
        V = Y;
        do {
            if (V != W) {
                U -= V.scrollTop || 0;
                X -= V.scrollLeft || 0
            }
        } while (V = V.parentNode);
        return new Element.Offset(X, U)
    }
    function Q(U) {
        U = $(U);
        if (Element.getStyle(U, "position") === "absolute") {
            return U
        }
        var Y = L(U);
        var X = U.viewportOffset(),
            V = Y.viewportOffset();
        var Z = X.relativeTo(V);
        var W = U.getLayout();
        U.store("prototype_absolutize_original_styles", {
            left: U.getStyle("left"),
            top: U.getStyle("top"),
            width: U.getStyle("width"),
            height: U.getStyle("height")
        });
        U.setStyle({
            position: "absolute",
            top: Z.top + "px",
            left: Z.left + "px",
            width: W.get("width") + "px",
            height: W.get("height") + "px"
        });
        return U
    }
    function I(V) {
        V = $(V);
        if (Element.getStyle(V, "position") === "relative") {
            return V
        }
        var U = V.retrieve("prototype_absolutize_original_styles");
        if (U) {
            V.setStyle(U)
        }
        return V
    }
    if (Prototype.Browser.IE) {
        L = L.wrap(function(W, V) {
            V = $(V);
            if (E(V) || C(V) || M(V) || K(V)) {
                return $(document.body)
            }
            var U = V.getStyle("position");
            if (U !== "static") {
                return W(V)
            }
            V.setStyle({
                position: "relative"
            });
            var X = W(V);
            V.setStyle({
                position: U
            });
            return X
        });
        P = P.wrap(function(X, V) {
            V = $(V);
            if (!V.parentNode) {
                return new Element.Offset(0, 0)
            }
            var U = V.getStyle("position");
            if (U !== "static") {
                return X(V)
            }
            var W = V.getOffsetParent();
            if (W && W.getStyle("position") === "fixed") {
                D(W)
            }
            V.setStyle({
                position: "relative"
            });
            var Y = X(V);
            V.setStyle({
                position: U
            });
            return Y
        })
    } else {
        if (Prototype.Browser.Webkit) {
            T = function(V) {
                V = $(V);
                var U = 0,
                    W = 0;
                do {
                    U += V.offsetTop || 0;
                    W += V.offsetLeft || 0;
                    if (V.offsetParent == document.body) {
                        if (Element.getStyle(V, "position") == "absolute") {
                            break
                        }
                    }
                    V = V.offsetParent
                } while (V);
                return new Element.Offset(W, U)
            }
        }
    }
    Element.addMethods({
        getLayout: R,
        measure: B,
        getDimensions: N,
        getOffsetParent: L,
        cumulativeOffset: T,
        positionedOffset: P,
        cumulativeScrollOffset: A,
        viewportOffset: S,
        absolutize: Q,
        relativize: I
    });

    function M(U) {
        return U.nodeName.toUpperCase() === "BODY"
    }
    function K(U) {
        return U.nodeName.toUpperCase() === "HTML"
    }
    function E(U) {
        return U.nodeType === Node.DOCUMENT_NODE
    }
    function C(U) {
        return U !== document.body && !Element.descendantOf(U, document.body)
    }
    if ("getBoundingClientRect" in document.documentElement) {
        Element.addMethods({
            viewportOffset: function(U) {
                U = $(U);
                if (C(U)) {
                    return new Element.Offset(0, 0)
                }
                var V = U.getBoundingClientRect(),
                    W = document.documentElement;
                return new Element.Offset(V.left - W.clientLeft, V.top - W.clientTop)
            }
        })
    }
})();
window.$$ = function() {
    var A = $A(arguments).join(", ");
    return Prototype.Selector.select(A, document)
};
Prototype.Selector = (function() {
    function A() {
        throw new Error('Method "Prototype.Selector.select" must be defined.')
    }
    function C() {
        throw new Error('Method "Prototype.Selector.match" must be defined.')
    }
    function D(K, L, H) {
        H = H || 0;
        var G = Prototype.Selector.match,
            J = K.length,
            F = 0,
            I;
        for (I = 0;
        I < J; I++) {
            if (G(K[I], L) && H == F++) {
                return Element.extend(K[I])
            }
        }
    }
    function E(H) {
        for (var F = 0, G = H.length;
        F < G; F++) {
            Element.extend(H[F])
        }
        return H
    }
    var B = Prototype.K;
    return {
        select: A,
        match: C,
        find: D,
        extendElements: (Element.extend === B) ? B : E,
        extendElement: Element.extend
    }
})();
Prototype._original_property = window.Sizzle;
/*
 * Sizzle CSS Selector Engine - v1.0
 *  Copyright 2009, The Dojo Foundation
 *  Released under the MIT, BSD, and GPL Licenses.
 *  More information: http://sizzlejs.com/
 */
(function() {
    var P = /((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^[\]]*\]|['"][^'"]*['"]|[^[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/g,
        I = 0,
        D = Object.prototype.toString,
        N = false,
        H = true;
    [0, 0].sort(function() {
        H = false;
        return 0
    });
    var B = function(e, U, b, W) {
        b = b || [];
        var R = U = U || document;
        if (U.nodeType !== 1 && U.nodeType !== 9) {
            return []
        }
        if (!e || typeof e !== "string") {
            return b
        }
        var c = [],
            d, Z, j, h, a, T, S = true,
            X = O(U),
            g = e;
        while ((P.exec(""), d = P.exec(g)) !== null) {
            g = d[3];
            c.push(d[1]);
            if (d[2]) {
                T = d[3];
                break
            }
        }
        if (c.length > 1 && J.exec(e)) {
            if (c.length === 2 && E.relative[c[0]]) {
                Z = F(c[0] + c[1], U)
            } else {
                Z = E.relative[c[0]] ? [U] : B(c.shift(), U);
                while (c.length) {
                    e = c.shift();
                    if (E.relative[e]) {
                        e += c.shift()
                    }
                    Z = F(e, Z)
                }
            }
        } else {
            if (!W && c.length > 1 && U.nodeType === 9 && !X && E.match.ID.test(c[0]) && !E.match.ID.test(c[c.length - 1])) {
                var k = B.find(c.shift(), U, X);
                U = k.expr ? B.filter(k.expr, k.set)[0] : k.set[0]
            }
            if (U) {
                var k = W ? {
                    expr: c.pop(),
                    set: A(W)
                } : B.find(c.pop(), c.length === 1 && (c[0] === "~" || c[0] === "+") && U.parentNode ? U.parentNode : U, X);
                Z = k.expr ? B.filter(k.expr, k.set) : k.set;
                if (c.length > 0) {
                    j = A(Z)
                } else {
                    S = false
                }
                while (c.length) {
                    var V = c.pop(),
                        Y = V;
                    if (!E.relative[V]) {
                        V = ""
                    } else {
                        Y = c.pop()
                    }
                    if (Y == null) {
                        Y = U
                    }
                    E.relative[V](j, Y, X)
                }
            } else {
                j = c = []
            }
        }
        if (!j) {
            j = Z
        }
        if (!j) {
            throw "Syntax error, unrecognized expression: " + (V || e)
        }
        if (D.call(j) === "[object Array]") {
            if (!S) {
                b.push.apply(b, j)
            } else {
                if (U && U.nodeType === 1) {
                    for (var f = 0; j[f] != null; f++) {
                        if (j[f] && (j[f] === true || j[f].nodeType === 1 && G(U, j[f]))) {
                            b.push(Z[f])
                        }
                    }
                } else {
                    for (var f = 0; j[f] != null; f++) {
                        if (j[f] && j[f].nodeType === 1) {
                            b.push(Z[f])
                        }
                    }
                }
            }
        } else {
            A(j, b)
        }
        if (T) {
            B(T, R, b, W);
            B.uniqueSort(b)
        }
        return b
    };
    B.uniqueSort = function(S) {
        if (C) {
            N = H;
            S.sort(C);
            if (N) {
                for (var R = 1; R < S.length; R++) {
                    if (S[R] === S[R - 1]) {
                        S.splice(R--, 1)
                    }
                }
            }
        }
        return S
    };
    B.matches = function(R, S) {
        return B(R, null, null, S)
    };
    B.find = function(Y, R, Z) {
        var X, V;
        if (!Y) {
            return []
        }
        for (var U = 0, T = E.order.length; U < T; U++) {
            var W = E.order[U],
                V;
            if ((V = E.leftMatch[W].exec(Y))) {
                var S = V[1];
                V.splice(1, 1);
                if (S.substr(S.length - 1) !== "\\") {
                    V[1] = (V[1] || "").replace(/\\/g, "");
                    X = E.find[W](V, R, Z);
                    if (X != null) {
                        Y = Y.replace(E.match[W], "");
                        break
                    }
                }
            }
        }
        if (!X) {
            X = R.getElementsByTagName("*")
        }
        return {
            set: X,
            expr: Y
        }
    };
    B.filter = function(b, a, e, U) {
        var T = b,
            g = [],
            Y = a,
            W, R, X = a && a[0] && O(a[0]);
        while (b && a.length) {
            for (var Z in E.filter) {
                if ((W = E.match[Z].exec(b)) != null) {
                    var S = E.filter[Z],
                        f, d;
                    R = false;
                    if (Y == g) {
                        g = []
                    }
                    if (E.preFilter[Z]) {
                        W = E.preFilter[Z](W, Y, e, g, U, X);
                        if (!W) {
                            R = f = true
                        } else {
                            if (W === true) {
                                continue
                            }
                        }
                    }
                    if (W) {
                        for (var V = 0;
                        (d = Y[V]) != null; V++) {
                            if (d) {
                                f = S(d, W, V, Y);
                                var c = U ^ !! f;
                                if (e && f != null) {
                                    if (c) {
                                        R = true
                                    } else {
                                        Y[V] = false
                                    }
                                } else {
                                    if (c) {
                                        g.push(d);
                                        R = true
                                    }
                                }
                            }
                        }
                    }
                    if (f !== undefined) {
                        if (!e) {
                            Y = g
                        }
                        b = b.replace(E.match[Z], "");
                        if (!R) {
                            return []
                        }
                        break
                    }
                }
            }
            if (b == T) {
                if (R == null) {
                    throw "Syntax error, unrecognized expression: " + b
                } else {
                    break
                }
            }
            T = b
        }
        return Y
    };
    var E = B.selectors = {
        order: ["ID", "NAME", "TAG"],
        match: {
            ID: /#((?:[\w\u00c0-\uFFFF-]|\\.)+)/,
            CLASS: /\.((?:[\w\u00c0-\uFFFF-]|\\.)+)/,
            NAME: /\[name=['"]*((?:[\w\u00c0-\uFFFF-]|\\.)+)['"]*\]/,
            ATTR: /\[\s*((?:[\w\u00c0-\uFFFF-]|\\.)+)\s*(?:(\S?=)\s*(['"]*)(.*?)\3|)\s*\]/,
            TAG: /^((?:[\w\u00c0-\uFFFF\*-]|\\.)+)/,
            CHILD: /:(only|nth|last|first)-child(?:\((even|odd|[\dn+-]*)\))?/,
            POS: /:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^-]|$)/,
            PSEUDO: /:((?:[\w\u00c0-\uFFFF-]|\\.)+)(?:\((['"]*)((?:\([^\)]+\)|[^\2\(\)]*)+)\2\))?/
        },
        leftMatch: {},
        attrMap: {
            "class": "className",
            "for": "htmlFor"
        },
        attrHandle: {
            href: function(R) {
                return R.getAttribute("href")
            }
        },
        relative: {
            "+": function(Y, R, X) {
                var V = typeof R === "string",
                    Z = V && !/\W/.test(R),
                    W = V && !Z;
                if (Z && !X) {
                    R = R.toUpperCase()
                }
                for (var U = 0, T = Y.length, S; U < T; U++) {
                    if ((S = Y[U])) {
                        while ((S = S.previousSibling) && S.nodeType !== 1) {}
                        Y[U] = W || S && S.nodeName === R ? S || false : S === R
                    }
                }
                if (W) {
                    B.filter(R, Y, true)
                }
            },
            ">": function(X, S, Y) {
                var V = typeof S === "string";
                if (V && !/\W/.test(S)) {
                    S = Y ? S : S.toUpperCase();
                    for (var T = 0, R = X.length; T < R; T++) {
                        var W = X[T];
                        if (W) {
                            var U = W.parentNode;
                            X[T] = U.nodeName === S ? U : false
                        }
                    }
                } else {
                    for (var T = 0, R = X.length; T < R; T++) {
                        var W = X[T];
                        if (W) {
                            X[T] = V ? W.parentNode : W.parentNode === S
                        }
                    }
                    if (V) {
                        B.filter(S, X, true)
                    }
                }
            },
            "": function(U, S, W) {
                var T = I++,
                    R = Q;
                if (!/\W/.test(S)) {
                    var V = S = W ? S : S.toUpperCase();
                    R = M
                }
                R("parentNode", S, T, U, V, W)
            },
            "~": function(U, S, W) {
                var T = I++,
                    R = Q;
                if (typeof S === "string" && !/\W/.test(S)) {
                    var V = S = W ? S : S.toUpperCase();
                    R = M
                }
                R("previousSibling", S, T, U, V, W)
            }
        },
        find: {
            ID: function(S, T, U) {
                if (typeof T.getElementById !== "undefined" && !U) {
                    var R = T.getElementById(S[1]);
                    return R ? [R] : []
                }
            },
            NAME: function(T, W, X) {
                if (typeof W.getElementsByName !== "undefined") {
                    var S = [],
                        V = W.getElementsByName(T[1]);
                    for (var U = 0, R = V.length; U < R; U++) {
                        if (V[U].getAttribute("name") === T[1]) {
                            S.push(V[U])
                        }
                    }
                    return S.length === 0 ? null : S
                }
            },
            TAG: function(R, S) {
                return S.getElementsByTagName(R[1])
            }
        },
        preFilter: {
            CLASS: function(U, S, T, R, X, Y) {
                U = " " + U[1].replace(/\\/g, "") + " ";
                if (Y) {
                    return U
                }
                for (var V = 0, W;
                (W = S[V]) != null; V++) {
                    if (W) {
                        if (X ^ (W.className && (" " + W.className + " ").indexOf(U) >= 0)) {
                            if (!T) {
                                R.push(W)
                            }
                        } else {
                            if (T) {
                                S[V] = false
                            }
                        }
                    }
                }
                return false
            },
            ID: function(R) {
                return R[1].replace(/\\/g, "")
            },
            TAG: function(S, R) {
                for (var T = 0; R[T] === false; T++) {}
                return R[T] && O(R[T]) ? S[1] : S[1].toUpperCase()
            },
            CHILD: function(R) {
                if (R[1] == "nth") {
                    var S = /(-?)(\d*)n((?:\+|-)?\d*)/.exec(R[2] == "even" && "2n" || R[2] == "odd" && "2n+1" || !/\D/.test(R[2]) && "0n+" + R[2] || R[2]);
                    R[2] = (S[1] + (S[2] || 1)) - 0;
                    R[3] = S[3] - 0
                }
                R[0] = I++;
                return R
            },
            ATTR: function(V, S, T, R, W, X) {
                var U = V[1].replace(/\\/g, "");
                if (!X && E.attrMap[U]) {
                    V[1] = E.attrMap[U]
                }
                if (V[2] === "~=") {
                    V[4] = " " + V[4] + " "
                }
                return V
            },
            PSEUDO: function(V, S, T, R, W) {
                if (V[1] === "not") {
                    if ((P.exec(V[3]) || "").length > 1 || /^\w/.test(V[3])) {
                        V[3] = B(V[3], null, null, S)
                    } else {
                        var U = B.filter(V[3], S, T, true ^ W);
                        if (!T) {
                            R.push.apply(R, U)
                        }
                        return false
                    }
                } else {
                    if (E.match.POS.test(V[0]) || E.match.CHILD.test(V[0])) {
                        return true
                    }
                }
                return V
            },
            POS: function(R) {
                R.unshift(true);
                return R
            }
        },
        filters: {
            enabled: function(R) {
                return R.disabled === false && R.type !== "hidden"
            },
            disabled: function(R) {
                return R.disabled === true
            },
            checked: function(R) {
                return R.checked === true
            },
            selected: function(R) {
                R.parentNode.selectedIndex;
                return R.selected === true
            },
            parent: function(R) {
                return !!R.firstChild
            },
            empty: function(R) {
                return !R.firstChild
            },
            has: function(T, S, R) {
                return !!B(R[3], T).length
            },
            header: function(R) {
                return /h\d/i.test(R.nodeName)
            },
            text: function(R) {
                return "text" === R.type
            },
            radio: function(R) {
                return "radio" === R.type
            },
            checkbox: function(R) {
                return "checkbox" === R.type
            },
            file: function(R) {
                return "file" === R.type
            },
            password: function(R) {
                return "password" === R.type
            },
            submit: function(R) {
                return "submit" === R.type
            },
            image: function(R) {
                return "image" === R.type
            },
            reset: function(R) {
                return "reset" === R.type
            },
            button: function(R) {
                return "button" === R.type || R.nodeName.toUpperCase() === "BUTTON"
            },
            input: function(R) {
                return /input|select|textarea|button/i.test(R.nodeName)
            }
        },
        setFilters: {
            first: function(S, R) {
                return R === 0
            },
            last: function(T, S, R, U) {
                return S === U.length - 1
            },
            even: function(S, R) {
                return R % 2 === 0
            },
            odd: function(S, R) {
                return R % 2 === 1
            },
            lt: function(T, S, R) {
                return S < R[3] - 0
            },
            gt: function(T, S, R) {
                return S > R[3] - 0
            },
            nth: function(T, S, R) {
                return R[3] - 0 == S
            },
            eq: function(T, S, R) {
                return R[3] - 0 == S
            }
        },
        filter: {
            PSEUDO: function(X, T, U, Y) {
                var S = T[1],
                    V = E.filters[S];
                if (V) {
                    return V(X, U, T, Y)
                } else {
                    if (S === "contains") {
                        return (X.textContent || X.innerText || "").indexOf(T[3]) >= 0
                    } else {
                        if (S === "not") {
                            var W = T[3];
                            for (var U = 0, R = W.length; U < R; U++) {
                                if (W[U] === X) {
                                    return false
                                }
                            }
                            return true
                        }
                    }
                }
            },
            CHILD: function(R, U) {
                var X = U[1],
                    S = R;
                switch (X) {
                case "only":
                case "first":
                    while ((S = S.previousSibling)) {
                        if (S.nodeType === 1) {
                            return false
                        }
                    }
                    if (X == "first") {
                        return true
                    }
                    S = R;
                case "last":
                    while ((S = S.nextSibling)) {
                        if (S.nodeType === 1) {
                            return false
                        }
                    }
                    return true;
                case "nth":
                    var T = U[2],
                        a = U[3];
                    if (T == 1 && a == 0) {
                        return true
                    }
                    var W = U[0],
                        Z = R.parentNode;
                    if (Z && (Z.sizcache !== W || !R.nodeIndex)) {
                        var V = 0;
                        for (S = Z.firstChild; S; S = S.nextSibling) {
                            if (S.nodeType === 1) {
                                S.nodeIndex = ++V
                            }
                        }
                        Z.sizcache = W
                    }
                    var Y = R.nodeIndex - a;
                    if (T == 0) {
                        return Y == 0
                    } else {
                        return (Y % T == 0 && Y / T >= 0)
                    }
                }
            },
            ID: function(S, R) {
                return S.nodeType === 1 && S.getAttribute("id") === R
            },
            TAG: function(S, R) {
                return (R === "*" && S.nodeType === 1) || S.nodeName === R
            },
            CLASS: function(S, R) {
                return (" " + (S.className || S.getAttribute("class")) + " ").indexOf(R) > -1
            },
            ATTR: function(W, U) {
                var T = U[1],
                    R = E.attrHandle[T] ? E.attrHandle[T](W) : W[T] != null ? W[T] : W.getAttribute(T),
                    X = R + "",
                    V = U[2],
                    S = U[4];
                return R == null ? V === "!=" : V === "=" ? X === S : V === "*=" ? X.indexOf(S) >= 0 : V === "~=" ? (" " + X + " ").indexOf(S) >= 0 : !S ? X && R !== false : V === "!=" ? X != S : V === "^=" ? X.indexOf(S) === 0 : V === "$=" ? X.substr(X.length - S.length) === S : V === "|=" ? X === S || X.substr(0, S.length + 1) === S + "-" : false
            },
            POS: function(V, S, T, W) {
                var R = S[2],
                    U = E.setFilters[R];
                if (U) {
                    return U(V, T, S, W)
                }
            }
        }
    };
    var J = E.match.POS;
    for (var L in E.match) {
        E.match[L] = new RegExp(E.match[L].source + /(?![^\[]*\])(?![^\(]*\))/.source);
        E.leftMatch[L] = new RegExp(/(^(?:.|\r|\n)*?)/.source + E.match[L].source)
    }
    var A = function(S, R) {
        S = Array.prototype.slice.call(S, 0);
        if (R) {
            R.push.apply(R, S);
            return R
        }
        return S
    };
    try {
        Array.prototype.slice.call(document.documentElement.childNodes, 0)
    } catch (K) {
        A = function(V, U) {
            var S = U || [];
            if (D.call(V) === "[object Array]") {
                Array.prototype.push.apply(S, V)
            } else {
                if (typeof V.length === "number") {
                    for (var T = 0, R = V.length; T < R; T++) {
                        S.push(V[T])
                    }
                } else {
                    for (var T = 0; V[T]; T++) {
                        S.push(V[T])
                    }
                }
            }
            return S
        }
    }
    var C;
    if (document.documentElement.compareDocumentPosition) {
        C = function(S, R) {
            if (!S.compareDocumentPosition || !R.compareDocumentPosition) {
                if (S == R) {
                    N = true
                }
                return 0
            }
            var T = S.compareDocumentPosition(R) & 4 ? -1 : S === R ? 0 : 1;
            if (T === 0) {
                N = true
            }
            return T
        }
    } else {
        if ("sourceIndex" in document.documentElement) {
            C = function(S, R) {
                if (!S.sourceIndex || !R.sourceIndex) {
                    if (S == R) {
                        N = true
                    }
                    return 0
                }
                var T = S.sourceIndex - R.sourceIndex;
                if (T === 0) {
                    N = true
                }
                return T
            }
        } else {
            if (document.createRange) {
                C = function(U, S) {
                    if (!U.ownerDocument || !S.ownerDocument) {
                        if (U == S) {
                            N = true
                        }
                        return 0
                    }
                    var T = U.ownerDocument.createRange(),
                        R = S.ownerDocument.createRange();
                    T.setStart(U, 0);
                    T.setEnd(U, 0);
                    R.setStart(S, 0);
                    R.setEnd(S, 0);
                    var V = T.compareBoundaryPoints(Range.START_TO_END, R);
                    if (V === 0) {
                        N = true
                    }
                    return V
                }
            }
        }
    }(function() {
        var S = document.createElement("div"),
            T = "script" + (new Date).getTime();
        S.innerHTML = "<a name='" + T + "'/>";
        var R = document.documentElement;
        R.insertBefore(S, R.firstChild);
        if ( !! document.getElementById(T)) {
            E.find.ID = function(V, W, X) {
                if (typeof W.getElementById !== "undefined" && !X) {
                    var U = W.getElementById(V[1]);
                    return U ? U.id === V[1] || typeof U.getAttributeNode !== "undefined" && U.getAttributeNode("id").nodeValue === V[1] ? [U] : undefined : []
                }
            };
            E.filter.ID = function(W, U) {
                var V = typeof W.getAttributeNode !== "undefined" && W.getAttributeNode("id");
                return W.nodeType === 1 && V && V.nodeValue === U
            }
        }
        R.removeChild(S);
        R = S = null
    })();
    (function() {
        var R = document.createElement("div");
        R.appendChild(document.createComment(""));
        if (R.getElementsByTagName("*").length > 0) {
            E.find.TAG = function(S, W) {
                var V = W.getElementsByTagName(S[1]);
                if (S[1] === "*") {
                    var U = [];
                    for (var T = 0; V[T]; T++) {
                        if (V[T].nodeType === 1) {
                            U.push(V[T])
                        }
                    }
                    V = U
                }
                return V
            }
        }
        R.innerHTML = "<a href='#'></a>";
        if (R.firstChild && typeof R.firstChild.getAttribute !== "undefined" && R.firstChild.getAttribute("href") !== "#") {
            E.attrHandle.href = function(S) {
                return S.getAttribute("href", 2)
            }
        }
        R = null
    })();
    if (document.querySelectorAll) {
        (function() {
            var R = B,
                T = document.createElement("div");
            T.innerHTML = "<p class='TEST'></p>";
            if (T.querySelectorAll && T.querySelectorAll(".TEST").length === 0) {
                return
            }
            B = function(X, W, U, V) {
                W = W || document;
                if (!V && W.nodeType === 9 && !O(W)) {
                    try {
                        return A(W.querySelectorAll(X), U)
                    } catch (Y) {}
                }
                return R(X, W, U, V)
            };
            for (var S in R) {
                B[S] = R[S]
            }
            T = null
        })()
    }
    if (document.getElementsByClassName && document.documentElement.getElementsByClassName) {
        (function() {
            var R = document.createElement("div");
            R.innerHTML = "<div class='test e'></div><div class='test'></div>";
            if (R.getElementsByClassName("e").length === 0) {
                return
            }
            R.lastChild.className = "e";
            if (R.getElementsByClassName("e").length === 1) {
                return
            }
            E.order.splice(1, 0, "CLASS");
            E.find.CLASS = function(S, T, U) {
                if (typeof T.getElementsByClassName !== "undefined" && !U) {
                    return T.getElementsByClassName(S[1])
                }
            };
            R = null
        })()
    }
    function M(S, X, W, b, Y, a) {
        var Z = S == "previousSibling" && !a;
        for (var U = 0, T = b.length;
        U < T; U++) {
            var R = b[U];
            if (R) {
                if (Z && R.nodeType === 1) {
                    R.sizcache = W;
                    R.sizset = U
                }
                R = R[S];
                var V = false;
                while (R) {
                    if (R.sizcache === W) {
                        V = b[R.sizset];
                        break
                    }
                    if (R.nodeType === 1 && !a) {
                        R.sizcache = W;
                        R.sizset = U
                    }
                    if (R.nodeName === X) {
                        V = R;
                        break
                    }
                    R = R[S]
                }
                b[U] = V
            }
        }
    }
    function Q(S, X, W, b, Y, a) {
        var Z = S == "previousSibling" && !a;
        for (var U = 0, T = b.length; U < T; U++) {
            var R = b[U];
            if (R) {
                if (Z && R.nodeType === 1) {
                    R.sizcache = W;
                    R.sizset = U
                }
                R = R[S];
                var V = false;
                while (R) {
                    if (R.sizcache === W) {
                        V = b[R.sizset];
                        break
                    }
                    if (R.nodeType === 1) {
                        if (!a) {
                            R.sizcache = W;
                            R.sizset = U
                        }
                        if (typeof X !== "string") {
                            if (R === X) {
                                V = true;
                                break
                            }
                        } else {
                            if (B.filter(X, [R]).length > 0) {
                                V = R;
                                break
                            }
                        }
                    }
                    R = R[S]
                }
                b[U] = V
            }
        }
    }
    var G = document.compareDocumentPosition ?
    function(S, R) {
        return S.compareDocumentPosition(R) & 16
    } : function(S, R) {
        return S !== R && (S.contains ? S.contains(R) : true)
    };
    var O = function(R) {
        return R.nodeType === 9 && R.documentElement.nodeName !== "HTML" || !! R.ownerDocument && R.ownerDocument.documentElement.nodeName !== "HTML"
    };
    var F = function(R, Y) {
        var U = [],
            V = "",
            W, T = Y.nodeType ? [Y] : Y;
        while ((W = E.match.PSEUDO.exec(R))) {
            V += W[0];
            R = R.replace(E.match.PSEUDO, "")
        }
        R = E.relative[R] ? R + "*" : R;
        for (var X = 0, S = T.length; X < S;
        X++) {
            B(R, T[X], U)
        }
        return B.filter(V, U)
    };
    window.Sizzle = B
})();
(function(C) {
    var D = Prototype.Selector.extendElements;

    function A(E, F) {
        return D(C(E, F || document))
    }
    function B(F, E) {
        return C.matches(E, [F]).length == 1
    }
    Prototype.Selector.engine = C;
    Prototype.Selector.select = A;
    Prototype.Selector.match = B
})(Sizzle);
window.Sizzle = Prototype._original_property;
delete Prototype._original_property;
var Form = {
    reset: function(A) {
        A = $(A);
        A.reset();
        return A
    },
    serializeElements: function(H, D) {
        if (typeof D != "object") {
            D = {
                hash: !! D
            }
        } else {
            if (Object.isUndefined(D.hash)) {
                D.hash = true
            }
        }
        var E, G, A = false,
            F = D.submit,
            B, C;
        if (D.hash) {
            C = {};
            B = function(I, J, K) {
                if (J in I) {
                    if (!Object.isArray(I[J])) {
                        I[J] = [I[J]]
                    }
                    I[J].push(K)
                } else {
                    I[J] = K
                }
                return I
            }
        } else {
            C = "";
            B = function(I, J, K) {
                return I + (I ? "&" : "") + encodeURIComponent(J) + "=" + encodeURIComponent(K)
            }
        }
        return H.inject(C, function(I, J) {
            if (!J.disabled && J.name) {
                E = J.name;
                G = $(J).getValue();
                if (G != null && J.type != "file" && (J.type != "submit" || (!A && F !== false && (!F || E == F) && (A = true)))) {
                    I = B(I, E, G)
                }
            }
            return I
        })
    }
};
Form.Methods = {
    serialize: function(B, A) {
        return Form.serializeElements(Form.getElements(B), A)
    },
    getElements: function(E) {
        var F = $(E).getElementsByTagName("*"),
            D, A = [],
            C = Form.Element.Serializers;
        for (var B = 0; D = F[B]; B++) {
            A.push(D)
        }
        return A.inject([], function(G, H) {
            if (C[H.tagName.toLowerCase()]) {
                G.push(Element.extend(H))
            }
            return G
        })
    },
    getInputs: function(G, C, D) {
        G = $(G);
        var A = G.getElementsByTagName("input");
        if (!C && !D) {
            return $A(A).map(Element.extend)
        }
        for (var E = 0, H = [], F = A.length; E < F; E++) {
            var B = A[E];
            if ((C && B.type != C) || (D && B.name != D)) {
                continue
            }
            H.push(Element.extend(B))
        }
        return H
    },
    disable: function(A) {
        A = $(A);
        Form.getElements(A).invoke("disable");
        return A
    },
    enable: function(A) {
        A = $(A);
        Form.getElements(A).invoke("enable");
        return A
    },
    findFirstElement: function(B) {
        var C = $(B).getElements().findAll(function(D) {
            return "hidden" != D.type && !D.disabled
        });
        var A = C.findAll(function(D) {
            return D.hasAttribute("tabIndex") && D.tabIndex >= 0
        }).sortBy(function(D) {
            return D.tabIndex
        }).first();
        return A ? A : C.find(function(D) {
            return /^(?:input|select|textarea)$/i.test(D.tagName)
        })
    },
    focusFirstElement: function(B) {
        B = $(B);
        var A = B.findFirstElement();
        if (A) {
            A.activate()
        }
        return B
    },
    request: function(B, A) {
        B = $(B), A = Object.clone(A || {});
        var D = A.parameters,
            C = B.readAttribute("action") || "";
        if (C.blank()) {
            C = window.location.href
        }
        A.parameters = B.serialize(true);
        if (D) {
            if (Object.isString(D)) {
                D = D.toQueryParams()
            }
            Object.extend(A.parameters, D)
        }
        if (B.hasAttribute("method") && !A.method) {
            A.method = B.method
        }
        return new Ajax.Request(C, A)
    }
};
Form.Element = {
    focus: function(A) {
        $(A).focus();
        return A
    },
    select: function(A) {
        $(A).select();
        return A
    }
};
Form.Element.Methods = {
    serialize: function(A) {
        A = $(A);
        if (!A.disabled && A.name) {
            var B = A.getValue();
            if (B != undefined) {
                var C = {};
                C[A.name] = B;
                return Object.toQueryString(C)
            }
        }
        return ""
    },
    getValue: function(A) {
        A = $(A);
        var B = A.tagName.toLowerCase();
        return Form.Element.Serializers[B](A)
    },
    setValue: function(A, B) {
        A = $(A);
        var C = A.tagName.toLowerCase();
        Form.Element.Serializers[C](A, B);
        return A
    },
    clear: function(A) {
        $(A).value = "";
        return A
    },
    present: function(A) {
        return $(A).value != ""
    },
    activate: function(A) {
        A = $(A);
        try {
            A.focus();
            if (A.select && (A.tagName.toLowerCase() != "input" || !(/^(?:button|reset|submit)$/i.test(A.type)))) {
                A.select()
            }
        } catch (B) {}
        return A
    },
    disable: function(A) {
        A = $(A);
        A.disabled = true;
        return A
    },
    enable: function(A) {
        A = $(A);
        A.disabled = false;
        return A
    }
};
var Field = Form.Element;
var $F = Form.Element.Methods.getValue;
Form.Element.Serializers = (function() {
    function B(H, I) {
        switch (H.type.toLowerCase()) {
        case "checkbox":
        case "radio":
            return F(H, I);
        default:
            return E(H, I)
        }
    }
    function F(H, I) {
        if (Object.isUndefined(I)) {
            return H.checked ? H.value : null
        } else {
            H.checked = !! I
        }
    }
    function E(H, I) {
        if (Object.isUndefined(I)) {
            return H.value
        } else {
            H.value = I
        }
    }
    function A(J, M) {
        if (Object.isUndefined(M)) {
            return (J.type === "select-one" ? C : D)(J)
        }
        var I, K, N = !Object.isArray(M);
        for (var H = 0, L = J.length; H < L; H++) {
            I = J.options[H];
            K = this.optionValue(I);
            if (N) {
                if (K == M) {
                    I.selected = true;
                    return
                }
            } else {
                I.selected = M.include(K)
            }
        }
    }
    function C(I) {
        var H = I.selectedIndex;
        return H >= 0 ? G(I.options[H]) : null
    }
    function D(K) {
        var H, L = K.length;
        if (!L) {
            return null
        }
        for (var J = 0, H = []; J < L; J++) {
            var I = K.options[J];
            if (I.selected) {
                H.push(G(I))
            }
        }
        return H
    }
    function G(H) {
        return Element.hasAttribute(H, "value") ? H.value : H.text
    }
    return {
        input: B,
        inputSelector: F,
        textarea: E,
        select: A,
        selectOne: C,
        selectMany: D,
        optionValue: G,
        button: E
    }
})();
Abstract.TimedObserver = Class.create(PeriodicalExecuter, {
    initialize: function($super, A, B, C) {
        $super(C, B);
        this.element = $(A);
        this.lastValue = this.getValue()
    },
    execute: function() {
        var A = this.getValue();
        if (Object.isString(this.lastValue) && Object.isString(A) ? this.lastValue != A : String(this.lastValue) != String(A)) {
            this.callback(this.element, A);
            this.lastValue = A
        }
    }
});
Form.Element.Observer = Class.create(Abstract.TimedObserver, {
    getValue: function() {
        return Form.Element.getValue(this.element)
    }
});
Form.Observer = Class.create(Abstract.TimedObserver, {
    getValue: function() {
        return Form.serialize(this.element)
    }
});
Abstract.EventObserver = Class.create({
    initialize: function(A, B) {
        this.element = $(A);
        this.callback = B;
        this.lastValue = this.getValue();
        if (this.element.tagName.toLowerCase() == "form") {
            this.registerFormCallbacks()
        } else {
            this.registerCallback(this.element)
        }
    },
    onElementEvent: function() {
        var A = this.getValue();
        if (this.lastValue != A) {
            this.callback(this.element, A);
            this.lastValue = A
        }
    },
    registerFormCallbacks: function() {
        Form.getElements(this.element).each(this.registerCallback, this)
    },
    registerCallback: function(A) {
        if (A.type) {
            switch (A.type.toLowerCase()) {
            case "checkbox":
            case "radio":
                Event.observe(A, "click", this.onElementEvent.bind(this));
                break;
            default:
                Event.observe(A, "change", this.onElementEvent.bind(this));
                break
            }
        }
    }
});
Form.Element.EventObserver = Class.create(Abstract.EventObserver, {
    getValue: function() {
        return Form.Element.getValue(this.element)
    }
});
Form.EventObserver = Class.create(Abstract.EventObserver, {
    getValue: function() {
        return Form.serialize(this.element)
    }
});
(function() {
    var c = {
        KEY_BACKSPACE: 8,
        KEY_TAB: 9,
        KEY_RETURN: 13,
        KEY_ESC: 27,
        KEY_LEFT: 37,
        KEY_UP: 38,
        KEY_RIGHT: 39,
        KEY_DOWN: 40,
        KEY_DELETE: 46,
        KEY_HOME: 36,
        KEY_END: 35,
        KEY_PAGEUP: 33,
        KEY_PAGEDOWN: 34,
        KEY_INSERT: 45,
        cache: {}
    };
    var F = document.documentElement;
    var d = "onmouseenter" in F && "onmouseleave" in F;
    var A = function(e) {
        return false
    };
    if (window.attachEvent) {
        if (window.addEventListener) {
            A = function(e) {
                return !(e instanceof window.Event)
            }
        } else {
            A = function(e) {
                return true
            }
        }
    }
    var R;

    function a(f, e) {
        return f.which ? (f.which === e + 1) : (f.button === e)
    }
    var O = {
        0: 1,
        1: 4,
        2: 2
    };

    function Y(f, e) {
        return f.button === O[e]
    }
    function b(f, e) {
        switch (e) {
        case 0:
            return f.which == 1 && !f.metaKey;
        case 1:
            return f.which == 2 || (f.which == 1 && f.metaKey);
        case 2:
            return f.which == 3;
        default:
            return false
        }
    }
    if (window.attachEvent) {
        if (!window.addEventListener) {
            R = Y
        } else {
            R = function(f, e) {
                return A(f) ? Y(f, e) : a(f, e)
            }
        }
    } else {
        if (Prototype.Browser.WebKit) {
            R = b
        } else {
            R = a
        }
    }
    function V(e) {
        return R(e, 0)
    }
    function T(e) {
        return R(e, 1)
    }
    function N(e) {
        return R(e, 2)
    }
    function D(g) {
        g = c.extend(g);
        var f = g.target,
            e = g.type,
            h = g.currentTarget;
        if (h && h.tagName) {
            if (e === "load" || e === "error" || (e === "click" && h.tagName.toLowerCase() === "input" && h.type === "radio")) {
                f = h
            }
        }
        if (f.nodeType == Node.TEXT_NODE) {
            f = f.parentNode
        }
        return Element.extend(f)
    }
    function P(f, g) {
        var e = c.element(f);
        if (!g) {
            return e
        }
        while (e) {
            if (Object.isElement(e) && Prototype.Selector.match(e, g)) {
                return Element.extend(e)
            }
            e = e.parentNode
        }
    }
    function S(e) {
        return {
            x: C(e),
            y: B(e)
        }
    }
    function C(g) {
        var f = document.documentElement,
            e = document.body || {
                scrollLeft: 0
            };
        return g.pageX || (g.clientX + (f.scrollLeft || e.scrollLeft) - (f.clientLeft || 0))
    }
    function B(g) {
        var f = document.documentElement,
            e = document.body || {
                scrollTop: 0
            };
        return g.pageY || (g.clientY + (f.scrollTop || e.scrollTop) - (f.clientTop || 0))
    }
    function Q(e) {
        c.extend(e);
        e.preventDefault();
        e.stopPropagation();
        e.stopped = true
    }
    c.Methods = {
        isLeftClick: V,
        isMiddleClick: T,
        isRightClick: N,
        element: D,
        findElement: P,
        pointer: S,
        pointerX: C,
        pointerY: B,
        stop: Q
    };
    var X = Object.keys(c.Methods).inject({}, function(e, f) {
        e[f] = c.Methods[f].methodize();
        return e
    });
    if (window.attachEvent) {
        function I(f) {
            var e;
            switch (f.type) {
            case "mouseover":
            case "mouseenter":
                e = f.fromElement;
                break;
            case "mouseout":
            case "mouseleave":
                e = f.toElement;
                break;
            default:
                return null
            }
            return Element.extend(e)
        }
        var U = {
            stopPropagation: function() {
                this.cancelBubble = true
            },
            preventDefault: function() {
                this.returnValue = false
            },
            inspect: function() {
                return "[object Event]"
            }
        };
        c.extend = function(f, e) {
            if (!f) {
                return false
            }
            if (!A(f)) {
                return f
            }
            if (f._extendedByPrototype) {
                return f
            }
            f._extendedByPrototype = Prototype.emptyFunction;
            var g = c.pointer(f);
            Object.extend(f, {
                target: f.srcElement || e,
                relatedTarget: I(f),
                pageX: g.x,
                pageY: g.y
            });
            Object.extend(f, X);
            Object.extend(f, U);
            return f
        }
    } else {
        c.extend = Prototype.K
    }
    if (window.addEventListener) {
        c.prototype = window.Event.prototype || document.createEvent("HTMLEvents").__proto__;
        Object.extend(c.prototype, X)
    }
    function M(j, h, k) {
        var g = Element.retrieve(j, "prototype_event_registry");
        if (Object.isUndefined(g)) {
            E.push(j);
            g = Element.retrieve(j, "prototype_event_registry", $H())
        }
        var e = g.get(h);
        if (Object.isUndefined(e)) {
            e = [];
            g.set(h, e)
        }
        if (e.pluck("handler").include(k)) {
            return false
        }
        var f;
        if (h.include(":")) {
            f = function(l) {
                if (Object.isUndefined(l.eventName)) {
                    return false
                }
                if (l.eventName !== h) {
                    return false
                }
                c.extend(l, j);
                k.call(j, l)
            }
        } else {
            if (!d && (h === "mouseenter" || h === "mouseleave")) {
                if (h === "mouseenter" || h === "mouseleave") {
                    f = function(m) {
                        c.extend(m, j);
                        var l = m.relatedTarget;
                        while (l && l !== j) {
                            try {
                                l = l.parentNode
                            } catch (n) {
                                l = j
                            }
                        }
                        if (l === j) {
                            return
                        }
                        k.call(j, m)
                    }
                }
            } else {
                f = function(l) {
                    c.extend(l, j);
                    k.call(j, l)
                }
            }
        }
        f.handler = k;
        e.push(f);
        return f
    }
    function H() {
        for (var e = 0, f = E.length; e < f; e++) {
            c.stopObserving(E[e]);
            E[e] = null
        }
    }
    var E = [];
    if (Prototype.Browser.IE) {
        window.attachEvent("onunload", H)
    }
    if (Prototype.Browser.WebKit) {
        window.addEventListener("unload", Prototype.emptyFunction, false)
    }
    var L = Prototype.K,
        G = {
            mouseenter: "mouseover",
            mouseleave: "mouseout"
        };
    if (!d) {
        L = function(e) {
            return (G[e] || e)
        }
    }
    function W(h, g, j) {
        h = $(h);
        var f = M(h, g, j);
        if (!f) {
            return h
        }
        if (g.include(":")) {
            if (h.addEventListener) {
                h.addEventListener("dataavailable", f, false)
            } else {
                h.attachEvent("ondataavailable", f);
                h.attachEvent("onlosecapture", f)
            }
        } else {
            var e = L(g);
            if (h.addEventListener) {
                h.addEventListener(e, f, false)
            } else {
                h.attachEvent("on" + e, f)
            }
        }
        return h
    }
    function K(l, h, m) {
        l = $(l);
        var g = Element.retrieve(l, "prototype_event_registry");
        if (!g) {
            return l
        }
        if (!h) {
            g.each(function(o) {
                var n = o.key;
                K(l, n)
            });
            return l
        }
        var j = g.get(h);
        if (!j) {
            return l
        }
        if (!m) {
            j.each(function(n) {
                K(l, h, n.handler)
            });
            return l
        }
        var k = j.length,
            f;
        while (k--) {
            if (j[k].handler === m) {
                f = j[k];
                break
            }
        }
        if (!f) {
            return l
        }
        if (h.include(":")) {
            if (l.removeEventListener) {
                l.removeEventListener("dataavailable", f, false)
            } else {
                l.detachEvent("ondataavailable", f);
                l.detachEvent("onlosecapture", f)
            }
        } else {
            var e = L(h);
            if (l.removeEventListener) {
                l.removeEventListener(e, f, false)
            } else {
                l.detachEvent("on" + e, f)
            }
        }
        g.set(h, j.without(f));
        return l
    }
    function Z(h, g, f, e) {
        h = $(h);
        if (Object.isUndefined(e)) {
            e = true
        }
        if (h == document && document.createEvent && !h.dispatchEvent) {
            h = document.documentElement
        }
        var j;
        if (document.createEvent) {
            j = document.createEvent("HTMLEvents");
            j.initEvent("dataavailable", e, true)
        } else {
            j = document.createEventObject();
            j.eventType = e ? "ondataavailable" : "onlosecapture"
        }
        j.eventName = g;
        j.memo = f || {};
        if (document.createEvent) {
            h.dispatchEvent(j)
        } else {
            h.fireEvent(j.eventType, j)
        }
        return c.extend(j)
    }
    c.Handler = Class.create({
        initialize: function(g, f, e, h) {
            this.element = $(g);
            this.eventName = f;
            this.selector = e;
            this.callback = h;
            this.handler = this.handleEvent.bind(this)
        },
        start: function() {
            c.observe(this.element, this.eventName, this.handler);
            return this
        },
        stop: function() {
            c.stopObserving(this.element, this.eventName, this.handler);
            return this
        },
        handleEvent: function(f) {
            var e = c.findElement(f, this.selector);
            if (e) {
                this.callback.call(this.element, f, e)
            }
        }
    });

    function J(g, f, e, h) {
        g = $(g);
        if (Object.isFunction(e) && Object.isUndefined(h)) {
            h = e, e = null
        }
        return new c.Handler(g, f, e, h).start()
    }
    Object.extend(c, c.Methods);
    Object.extend(c, {
        fire: Z,
        observe: W,
        stopObserving: K,
        on: J
    });
    Element.addMethods({
        fire: Z,
        observe: W,
        stopObserving: K,
        on: J
    });
    Object.extend(document, {
        fire: Z.methodize(),
        observe: W.methodize(),
        stopObserving: K.methodize(),
        on: J.methodize(),
        loaded: false
    });
    if (window.Event) {
        Object.extend(window.Event, c)
    } else {
        window.Event = c
    }
})();
(function() {
    var D;

    function A() {
        if (document.loaded) {
            return
        }
        if (D) {
            window.clearTimeout(D)
        }
        document.loaded = true;
        document.fire("dom:loaded")
    }
    function C() {
        if (document.readyState === "complete") {
            document.stopObserving("readystatechange", C);
            A()
        }
    }
    function B() {
        try {
            document.documentElement.doScroll("left")
        } catch (E) {
            D = B.defer();
            return
        }
        A()
    }
    if (document.addEventListener) {
        document.addEventListener("DOMContentLoaded", A, false)
    } else {
        document.observe("readystatechange", C);
        if (window == top) {
            D = B.defer()
        }
    }
    Event.observe(window, "load", A)
})();
Element.addMethods();
Hash.toQueryString = Object.toQueryString;
var Toggle = {
    display: Element.toggle
};
Element.Methods.childOf = Element.Methods.descendantOf;
var Insertion = {
    Before: function(A, B) {
        return Element.insert(A, {
            before: B
        })
    },
    Top: function(A, B) {
        return Element.insert(A, {
            top: B
        })
    },
    Bottom: function(A, B) {
        return Element.insert(A, {
            bottom: B
        })
    },
    After: function(A, B) {
        return Element.insert(A, {
            after: B
        })
    }
};
var $continue = new Error('"throw $continue" is deprecated, use "return" instead');
var Position = {
    includeScrollOffsets: false,
    prepare: function() {
        this.deltaX = window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft || 0;
        this.deltaY = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0
    },
    within: function(B, A, C) {
        if (this.includeScrollOffsets) {
            return this.withinIncludingScrolloffsets(B, A, C)
        }
        this.xcomp = A;
        this.ycomp = C;
        this.offset = Element.cumulativeOffset(B);
        return (C >= this.offset[1] && C < this.offset[1] + B.offsetHeight && A >= this.offset[0] && A < this.offset[0] + B.offsetWidth)
    },
    withinIncludingScrolloffsets: function(B, A, D) {
        var C = Element.cumulativeScrollOffset(B);
        this.xcomp = A + C[0] - this.deltaX;
        this.ycomp = D + C[1] - this.deltaY;
        this.offset = Element.cumulativeOffset(B);
        return (this.ycomp >= this.offset[1] && this.ycomp < this.offset[1] + B.offsetHeight && this.xcomp >= this.offset[0] && this.xcomp < this.offset[0] + B.offsetWidth)
    },
    overlap: function(B, A) {
        if (!B) {
            return 0
        }
        if (B == "vertical") {
            return ((this.offset[1] + A.offsetHeight) - this.ycomp) / A.offsetHeight
        }
        if (B == "horizontal") {
            return ((this.offset[0] + A.offsetWidth) - this.xcomp) / A.offsetWidth
        }
    },
    cumulativeOffset: Element.Methods.cumulativeOffset,
    positionedOffset: Element.Methods.positionedOffset,
    absolutize: function(A) {
        Position.prepare();
        return Element.absolutize(A)
    },
    relativize: function(A) {
        Position.prepare();
        return Element.relativize(A)
    },
    realOffset: Element.Methods.cumulativeScrollOffset,
    offsetParent: Element.Methods.getOffsetParent,
    page: Element.Methods.viewportOffset,
    clone: function(B, C, A) {
        A = A || {};
        return Element.clonePosition(C, B, A)
    }
};
if (!document.getElementsByClassName) {
    document.getElementsByClassName = function(B) {
        function A(C) {
            return C.blank() ? null : "[contains(concat(' ', @class, ' '), ' " + C + " ')]"
        }
        B.getElementsByClassName = Prototype.BrowserFeatures.XPath ?
        function(C, E) {
            E = E.toString().strip();
            var D = /\s/.test(E) ? $w(E).map(A).join("") : A(E);
            return D ? document._getElementsByXPath(".//*" + D, C) : []
        } : function(E, F) {
            F = F.toString().strip();
            var G = [],
                H = (/\s/.test(F) ? $w(F) : null);
            if (!H && !F) {
                return G
            }
            var C = $(E).getElementsByTagName("*");
            F = " " + F + " ";
            for (var D = 0, J, I; J = C[D]; D++) {
                if (J.className && (I = " " + J.className + " ") && (I.include(F) || (H && H.all(function(K) {
                    return !K.toString().blank() && I.include(" " + K + " ")
                })))) {
                    G.push(Element.extend(J))
                }
            }
            return G
        };
        return function(D, C) {
            return $(C || document.body).getElementsByClassName(D)
        }
    }(Element.Methods)
}
Element.ClassNames = Class.create();
Element.ClassNames.prototype = {
    initialize: function(A) {
        this.element = $(A)
    },
    _each: function(A) {
        this.element.className.split(/\s+/).select(function(B) {
            return B.length > 0
        })._each(A)
    },
    set: function(A) {
        this.element.className = A
    },
    add: function(A) {
        if (this.include(A)) {
            return
        }
        this.set($A(this).concat(A).join(" "))
    },
    remove: function(A) {
        if (!this.include(A)) {
            return
        }
        this.set($A(this).without(A).join(" "))
    },
    toString: function() {
        return $A(this).join(" ")
    }
};
Object.extend(Element.ClassNames.prototype, Enumerable);
(function() {
    window.Selector = Class.create({
        initialize: function(A) {
            this.expression = A.strip()
        },
        findElements: function(A) {
            return Prototype.Selector.select(this.expression, A)
        },
        match: function(A) {
            return Prototype.Selector.match(A, this.expression)
        },
        toString: function() {
            return this.expression
        },
        inspect: function() {
            return "#<Selector: " + this.expression + ">"
        }
    });
    Object.extend(Selector, {
        matchElements: function(F, G) {
            var A = Prototype.Selector.match,
                D = [];
            for (var C = 0, E = F.length; C < E; C++) {
                var B = F[C];
                if (A(B, G)) {
                    D.push(Element.extend(B))
                }
            }
            return D
        },
        findElement: function(F, G, B) {
            B = B || 0;
            var A = 0,
                D;
            for (var C = 0, E = F.length; C < E; C++) {
                D = F[C];
                if (Prototype.Selector.match(D, G) && B === A++) {
                    return Element.extend(D)
                }
            }
        },
        findChildElements: function(B, C) {
            var A = C.toArray().join(", ");
            return Prototype.Selector.select(A, B || document)
        }
    })
})();
var Scriptaculous = {
    Version: "1.8.1",
    require: function(A) {
        document.write('<script type="text/javascript" src="' + A + '"><\/script>')
    },
    REQUIRED_PROTOTYPE: "1.6.0",
    load: function() {
        function A(B) {
            var C = B.split(".");
            return parseInt(C[0]) * 100000 + parseInt(C[1]) * 1000 + parseInt(C[2])
        }
        if ((typeof Prototype == "undefined") || (typeof Element == "undefined") || (typeof Element.Methods == "undefined") || (A(Prototype.Version) < A(Scriptaculous.REQUIRED_PROTOTYPE))) {
            throw ("script.aculo.us requires the Prototype JavaScript framework >= " + Scriptaculous.REQUIRED_PROTOTYPE)
        }
        $A(document.getElementsByTagName("script")).findAll(function(B) {
            return (B.src && B.src.match(/scriptaculous\.js(\?.*)?$/))
        }).each(function(C) {
            var D = C.src.replace(/scriptaculous\.js(\?.*)?$/, "");
            var B = C.src.match(/\?.*load=([a-z,]*)/);
            (B ? B[1] : "builder,effects,dragdrop,controls,slider,sound").split(",").each(function(E) {
                Scriptaculous.require(D + E + ".js")
            })
        })
    }
};
var Builder = {
    NODEMAP: {
        AREA: "map",
        CAPTION: "table",
        COL: "table",
        COLGROUP: "table",
        LEGEND: "fieldset",
        OPTGROUP: "select",
        OPTION: "select",
        PARAM: "object",
        TBODY: "table",
        TD: "table",
        TFOOT: "table",
        TH: "table",
        THEAD: "table",
        TR: "table"
    },
    node: function(A) {
        A = A.toUpperCase();
        var F = this.NODEMAP[A] || "div";
        var B = document.createElement(F);
        try {
            B.innerHTML = "<" + A + "></" + A + ">"
        } catch (E) {}
        var D = B.firstChild || null;
        if (D && (D.tagName.toUpperCase() != A)) {
            D = D.getElementsByTagName(A)[0]
        }
        if (!D) {
            D = document.createElement(A)
        }
        if (!D) {
            return
        }
        if (arguments[1]) {
            if (this._isStringOrNumber(arguments[1]) || (arguments[1] instanceof Array) || arguments[1].tagName) {
                this._children(D, arguments[1])
            } else {
                var C = this._attributes(arguments[1]);
                if (C.length) {
                    try {
                        B.innerHTML = "<" + A + " " + C + "></" + A + ">"
                    } catch (E) {}
                    D = B.firstChild || null;
                    if (!D) {
                        D = document.createElement(A);
                        for (attr in arguments[1]) {
                            D[attr == "class" ? "className" : attr] = arguments[1][attr]
                        }
                    }
                    if (D.tagName.toUpperCase() != A) {
                        D = B.getElementsByTagName(A)[0]
                    }
                }
            }
        }
        if (arguments[2]) {
            this._children(D, arguments[2])
        }
        return D
    },
    _text: function(A) {
        return document.createTextNode(A)
    },
    ATTR_MAP: {
        className: "class",
        htmlFor: "for"
    },
    _attributes: function(A) {
        var B = [];
        for (attribute in A) {
            B.push((attribute in this.ATTR_MAP ? this.ATTR_MAP[attribute] : attribute) + '="' + A[attribute].toString().escapeHTML().gsub(/"/, "&quot;") + '"')
        }
        return B.join(" ")
    },
    _children: function(B, A) {
        if (A.tagName) {
            B.appendChild(A);
            return
        }
        if (typeof A == "object") {
            A.flatten().each(function(C) {
                if (typeof C == "object") {
                    B.appendChild(C)
                } else {
                    if (Builder._isStringOrNumber(C)) {
                        B.appendChild(Builder._text(C))
                    }
                }
            })
        } else {
            if (Builder._isStringOrNumber(A)) {
                B.appendChild(Builder._text(A))
            }
        }
    },
    _isStringOrNumber: function(A) {
        return (typeof A == "string" || typeof A == "number")
    },
    build: function(B) {
        var A = this.node("div");
        $(A).update(B.strip());
        return A.down()
    },
    dump: function(B) {
        if (typeof B != "object" && typeof B != "function") {
            B = window
        }
        var A = ("A ABBR ACRONYM ADDRESS APPLET AREA B BASE BASEFONT BDO BIG BLOCKQUOTE BODY BR BUTTON CAPTION CENTER CITE CODE COL COLGROUP DD DEL DFN DIR DIV DL DT EM FIELDSET FONT FORM FRAME FRAMESET H1 H2 H3 H4 H5 H6 HEAD HR HTML I IFRAME IMG INPUT INS ISINDEX KBD LABEL LEGEND LI LINK MAP MENU META NOFRAMES NOSCRIPT OBJECT OL OPTGROUP OPTION P PARAM PRE Q S SAMP SCRIPT SELECT SMALL SPAN STRIKE STRONG STYLE SUB SUP TABLE TBODY TD TEXTAREA TFOOT TH THEAD TITLE TR TT U UL VAR").split(/\s+/);
        A.each(function(C) {
            B[C] = function() {
                return Builder.node.apply(Builder, [C].concat($A(arguments)))
            }
        })
    }
};
String.prototype.parseColor = function() {
    var A = "#";
    if (this.slice(0, 4) == "rgb(") {
        var C = this.slice(4, this.length - 1).split(",");
        var B = 0;
        do {
            A += parseInt(C[B]).toColorPart()
        } while (++B < 3)
    } else {
        if (this.slice(0, 1) == "#") {
            if (this.length == 4) {
                for (var B = 1;
                B < 4; B++) {
                    A += (this.charAt(B) + this.charAt(B)).toLowerCase()
                }
            }
            if (this.length == 7) {
                A = this.toLowerCase()
            }
        }
    }
    return (A.length == 7 ? A : (arguments[0] || this))
};
Element.collectTextNodes = function(A) {
    return $A($(A).childNodes).collect(function(B) {
        return (B.nodeType == 3 ? B.nodeValue : (B.hasChildNodes() ? Element.collectTextNodes(B) : ""))
    }).flatten().join("")
};
Element.collectTextNodesIgnoreClass = function(A, B) {
    return $A($(A).childNodes).collect(function(C) {
        return (C.nodeType == 3 ? C.nodeValue : ((C.hasChildNodes() && !Element.hasClassName(C, B)) ? Element.collectTextNodesIgnoreClass(C, B) : ""))
    }).flatten().join("")
};
Element.setContentZoom = function(A, B) {
    A = $(A);
    A.setStyle({
        fontSize: (B / 100) + "em"
    });
    if (Prototype.Browser.WebKit) {
        window.scrollBy(0, 0)
    }
    return A
};
Element.getInlineOpacity = function(A) {
    return $(A).style.opacity || ""
};
Element.forceRerendering = function(A) {
    try {
        A = $(A);
        var C = document.createTextNode(" ");
        A.appendChild(C);
        A.removeChild(C)
    } catch (B) {}
};
var Effect = {
    _elementDoesNotExistError: {
        name: "ElementDoesNotExistError",
        message: "The specified DOM element does not exist, but is required for this effect to operate"
    },
    Transitions: {
        linear: Prototype.K,
        sinoidal: function(A) {
            return (-Math.cos(A * Math.PI) / 2) + 0.5
        },
        reverse: function(A) {
            return 1 - A
        },
        flicker: function(A) {
            var A = ((-Math.cos(A * Math.PI) / 4) + 0.75) + Math.random() / 4;
            return A > 1 ? 1 : A
        },
        wobble: function(A) {
            return (-Math.cos(A * Math.PI * (9 * A)) / 2) + 0.5
        },
        pulse: function(B, A) {
            A = A || 5;
            return (((B % (1 / A)) * A).round() == 0 ? ((B * A * 2) - (B * A * 2).floor()) : 1 - ((B * A * 2) - (B * A * 2).floor()))
        },
        spring: function(A) {
            return 1 - (Math.cos(A * 4.5 * Math.PI) * Math.exp(-A * 6))
        },
        none: function(A) {
            return 0
        },
        full: function(A) {
            return 1
        }
    },
    DefaultOptions: {
        duration: 1,
        fps: 100,
        sync: false,
        from: 0,
        to: 1,
        delay: 0,
        queue: "parallel"
    },
    tagifyText: function(A) {
        var B = "position:relative";
        if (Prototype.Browser.IE) {
            B += ";zoom:1"
        }
        A = $(A);
        $A(A.childNodes).each(function(C) {
            if (C.nodeType == 3) {
                C.nodeValue.toArray().each(function(D) {
                    A.insertBefore(new Element("span", {
                        style: B
                    }).update(D == " " ? String.fromCharCode(160) : D), C)
                });
                Element.remove(C)
            }
        })
    },
    multiple: function(B, C) {
        var E;
        if (((typeof B == "object") || Object.isFunction(B)) && (B.length)) {
            E = B
        } else {
            E = $(B).childNodes
        }
        var A = Object.extend({
            speed: 0.1,
            delay: 0
        }, arguments[2] || {});
        var D = A.delay;
        $A(E).each(function(G, F) {
            new C(G, Object.extend(A, {
                delay: F * A.speed + D
            }))
        })
    },
    PAIRS: {
        slide: ["SlideDown", "SlideUp"],
        blind: ["BlindDown", "BlindUp"],
        appear: ["Appear", "Fade"]
    },
    toggle: function(B, C) {
        B = $(B);
        C = (C || "appear").toLowerCase();
        var A = Object.extend({
            queue: {
                position: "end",
                scope: (B.id || "global"),
                limit: 1
            }
        }, arguments[2] || {});
        Effect[B.visible() ? Effect.PAIRS[C][1] : Effect.PAIRS[C][0]](B, A)
    }
};
Effect.DefaultOptions.transition = Effect.Transitions.sinoidal;
Effect.ScopedQueue = Class.create(Enumerable, {
    initialize: function() {
        this.effects = [];
        this.interval = null
    },
    _each: function(A) {
        this.effects._each(A)
    },
    add: function(B) {
        var C = new Date().getTime();
        var A = Object.isString(B.options.queue) ? B.options.queue : B.options.queue.position;
        switch (A) {
        case "front":
            this.effects.findAll(function(D) {
                return D.state == "idle"
            }).each(function(D) {
                D.startOn += B.finishOn;
                D.finishOn += B.finishOn
            });
            break;
        case "with-last":
            C = this.effects.pluck("startOn").max() || C;
            break;
        case "end":
            C = this.effects.pluck("finishOn").max() || C;
            break
        }
        B.startOn += C;
        B.finishOn += C;
        if (!B.options.queue.limit || (this.effects.length < B.options.queue.limit)) {
            this.effects.push(B)
        }
        if (!this.interval) {
            this.interval = setInterval(this.loop.bind(this), 15)
        }
    },
    remove: function(A) {
        this.effects = this.effects.reject(function(B) {
            return B == A
        });
        if (this.effects.length == 0) {
            clearInterval(this.interval);
            this.interval = null
        }
    },
    loop: function() {
        var C = new Date().getTime();
        for (var B = 0, A = this.effects.length; B < A; B++) {
            this.effects[B] && this.effects[B].loop(C)
        }
    }
});
Effect.Queues = {
    instances: $H(),
    get: function(A) {
        if (!Object.isString(A)) {
            return A
        }
        return this.instances.get(A) || this.instances.set(A, new Effect.ScopedQueue())
    }
};
Effect.Queue = Effect.Queues.get("global");
Effect.Base = Class.create({
    position: null,
    start: function(options) {
        function codeForEvent(options, eventName) {
            return ((options[eventName + "Internal"] ? "this.options." + eventName + "Internal(this);" : "") + (options[eventName] ? "this.options." + eventName + "(this);" : ""))
        }
        if (options && options.transition === false) {
            options.transition = Effect.Transitions.linear
        }
        this.options = Object.extend(Object.extend({}, Effect.DefaultOptions), options || {});
        this.currentFrame = 0;
        this.state = "idle";
        this.startOn = this.options.delay * 1000;
        this.finishOn = this.startOn + (this.options.duration * 1000);
        this.fromToDelta = this.options.to - this.options.from;
        this.totalTime = this.finishOn - this.startOn;
        this.totalFrames = this.options.fps * this.options.duration;
        eval('this.render = function(pos){ if (this.state=="idle"){this.state="running";' + codeForEvent(this.options, "beforeSetup") + (this.setup ? "this.setup();" : "") + codeForEvent(this.options, "afterSetup") + '};if (this.state=="running"){pos=this.options.transition(pos)*' + this.fromToDelta + "+" + this.options.from + ";this.position=pos;" + codeForEvent(this.options, "beforeUpdate") + (this.update ? "this.update(pos);" : "") + codeForEvent(this.options, "afterUpdate") + "}}");
        this.event("beforeStart");
        if (!this.options.sync) {
            Effect.Queues.get(Object.isString(this.options.queue) ? "global" : this.options.queue.scope).add(this)
        }
    },
    loop: function(C) {
        if (C >= this.startOn) {
            if (C >= this.finishOn) {
                this.render(1);
                this.cancel();
                this.event("beforeFinish");
                if (this.finish) {
                    this.finish()
                }
                this.event("afterFinish");
                return
            }
            var B = (C - this.startOn) / this.totalTime,
                A = (B * this.totalFrames).round();
            if (A > this.currentFrame) {
                this.render(B);
                this.currentFrame = A
            }
        }
    },
    cancel: function() {
        if (!this.options.sync) {
            Effect.Queues.get(Object.isString(this.options.queue) ? "global" : this.options.queue.scope).remove(this)
        }
        this.state = "finished"
    },
    event: function(A) {
        if (this.options[A + "Internal"]) {
            this.options[A + "Internal"](this)
        }
        if (this.options[A]) {
            this.options[A](this)
        }
    },
    inspect: function() {
        var A = $H();
        for (property in this) {
            if (!Object.isFunction(this[property])) {
                A.set(property, this[property])
            }
        }
        return "#<Effect:" + A.inspect() + ",options:" + $H(this.options).inspect() + ">"
    }
});
Effect.Parallel = Class.create(Effect.Base, {
    initialize: function(A) {
        this.effects = A || [];
        this.start(arguments[1])
    },
    update: function(A) {
        this.effects.invoke("render", A)
    },
    finish: function(A) {
        this.effects.each(function(B) {
            B.render(1);
            B.cancel();
            B.event("beforeFinish");
            if (B.finish) {
                B.finish(A)
            }
            B.event("afterFinish")
        })
    }
});
Effect.Tween = Class.create(Effect.Base, {
    initialize: function(C, F, E) {
        C = Object.isString(C) ? $(C) : C;
        var B = $A(arguments),
            D = B.last(),
            A = B.length == 5 ? B[3] : null;
        this.method = Object.isFunction(D) ? D.bind(C) : Object.isFunction(C[D]) ? C[D].bind(C) : function(G) {
            C[D] = G
        };
        this.start(Object.extend({
            from: F,
            to: E
        }, A || {}))
    },
    update: function(A) {
        this.method(A)
    }
});
Effect.Event = Class.create(Effect.Base, {
    initialize: function() {
        this.start(Object.extend({
            duration: 0
        }, arguments[0] || {}))
    },
    update: Prototype.emptyFunction
});
Effect.Opacity = Class.create(Effect.Base, {
    initialize: function(B) {
        this.element = $(B);
        if (!this.element) {
            throw (Effect._elementDoesNotExistError)
        }
        if (Prototype.Browser.IE && (!this.element.currentStyle.hasLayout)) {
            this.element.setStyle({
                zoom: 1
            })
        }
        var A = Object.extend({
            from: this.element.getOpacity() || 0,
            to: 1
        }, arguments[1] || {});
        this.start(A)
    },
    update: function(A) {
        this.element.setOpacity(A)
    }
});
Effect.Move = Class.create(Effect.Base, {
    initialize: function(B) {
        this.element = $(B);
        if (!this.element) {
            throw (Effect._elementDoesNotExistError)
        }
        var A = Object.extend({
            x: 0,
            y: 0,
            mode: "relative"
        }, arguments[1] || {});
        this.start(A)
    },
    setup: function() {
        this.element.makePositioned();
        this.originalLeft = parseFloat(this.element.getStyle("left") || "0");
        this.originalTop = parseFloat(this.element.getStyle("top") || "0");
        if (this.options.mode == "absolute") {
            this.options.x = this.options.x - this.originalLeft;
            this.options.y = this.options.y - this.originalTop
        }
    },
    update: function(A) {
        this.element.setStyle({
            left: (this.options.x * A + this.originalLeft).round() + "px",
            top: (this.options.y * A + this.originalTop).round() + "px"
        })
    }
});
Effect.MoveBy = function(B, A, C) {
    return new Effect.Move(B, Object.extend({
        x: C,
        y: A
    }, arguments[3] || {}))
};
Effect.Scale = Class.create(Effect.Base, {
    initialize: function(B, C) {
        this.element = $(B);
        if (!this.element) {
            throw (Effect._elementDoesNotExistError)
        }
        var A = Object.extend({
            scaleX: true,
            scaleY: true,
            scaleContent: true,
            scaleFromCenter: false,
            scaleMode: "box",
            scaleFrom: 100,
            scaleTo: C
        }, arguments[2] || {});
        this.start(A)
    },
    setup: function() {
        this.restoreAfterFinish = this.options.restoreAfterFinish || false;
        this.elementPositioning = this.element.getStyle("position");
        this.originalStyle = {};
        ["top", "left", "width", "height", "fontSize"].each(function(B) {
            this.originalStyle[B] = this.element.style[B]
        }.bind(this));
        this.originalTop = this.element.offsetTop;
        this.originalLeft = this.element.offsetLeft;
        var A = this.element.getStyle("font-size") || "100%";
        ["em", "px", "%", "pt"].each(function(B) {
            if (A.indexOf(B) > 0) {
                this.fontSize = parseFloat(A);
                this.fontSizeType = B
            }
        }.bind(this));
        this.factor = (this.options.scaleTo - this.options.scaleFrom) / 100;
        this.dims = null;
        if (this.options.scaleMode == "box") {
            this.dims = [this.element.offsetHeight, this.element.offsetWidth]
        }
        if (/^content/.test(this.options.scaleMode)) {
            this.dims = [this.element.scrollHeight, this.element.scrollWidth]
        }
        if (!this.dims) {
            this.dims = [this.options.scaleMode.originalHeight, this.options.scaleMode.originalWidth]
        }
    },
    update: function(A) {
        var B = (this.options.scaleFrom / 100) + (this.factor * A);
        if (this.options.scaleContent && this.fontSize) {
            this.element.setStyle({
                fontSize: this.fontSize * B + this.fontSizeType
            })
        }
        this.setDimensions(this.dims[0] * B, this.dims[1] * B)
    },
    finish: function(A) {
        if (this.restoreAfterFinish) {
            this.element.setStyle(this.originalStyle)
        }
    },
    setDimensions: function(A, D) {
        var E = {};
        if (this.options.scaleX) {
            E.width = D.round() + "px"
        }
        if (this.options.scaleY) {
            E.height = A.round() + "px"
        }
        if (this.options.scaleFromCenter) {
            var C = (A - this.dims[0]) / 2;
            var B = (D - this.dims[1]) / 2;
            if (this.elementPositioning == "absolute") {
                if (this.options.scaleY) {
                    E.top = this.originalTop - C + "px"
                }
                if (this.options.scaleX) {
                    E.left = this.originalLeft - B + "px"
                }
            } else {
                if (this.options.scaleY) {
                    E.top = -C + "px"
                }
                if (this.options.scaleX) {
                    E.left = -B + "px"
                }
            }
        }
        this.element.setStyle(E)
    }
});
Effect.Highlight = Class.create(Effect.Base, {
    initialize: function(B) {
        this.element = $(B);
        if (!this.element) {
            throw (Effect._elementDoesNotExistError)
        }
        var A = Object.extend({
            startcolor: "#ffff99"
        }, arguments[1] || {});
        this.start(A)
    },
    setup: function() {
        if (this.element.getStyle("display") == "none") {
            this.cancel();
            return
        }
        this.oldStyle = {};
        if (!this.options.keepBackgroundImage) {
            this.oldStyle.backgroundImage = this.element.getStyle("background-image");
            this.element.setStyle({
                backgroundImage: "none"
            })
        }
        if (!this.options.endcolor) {
            this.options.endcolor = this.element.getStyle("background-color").parseColor("#ffffff")
        }
        if (!this.options.restorecolor) {
            this.options.restorecolor = this.element.getStyle("background-color")
        }
        this._base = $R(0, 2).map(function(A) {
            return parseInt(this.options.startcolor.slice(A * 2 + 1, A * 2 + 3), 16)
        }.bind(this));
        this._delta = $R(0, 2).map(function(A) {
            return parseInt(this.options.endcolor.slice(A * 2 + 1, A * 2 + 3), 16) - this._base[A]
        }.bind(this))
    },
    update: function(A) {
        this.element.setStyle({
            backgroundColor: $R(0, 2).inject("#", function(B, C, D) {
                return B + ((this._base[D] + (this._delta[D] * A)).round().toColorPart())
            }.bind(this))
        })
    },
    finish: function() {
        this.element.setStyle(Object.extend(this.oldStyle, {
            backgroundColor: this.options.restorecolor
        }))
    }
});
Effect.ScrollTo = function(D) {
    var C = arguments[1] || {},
        B = document.viewport.getScrollOffsets(),
        E = $(D).cumulativeOffset(),
        A = (window.height || document.body.scrollHeight) - document.viewport.getHeight();
    if (C.offset) {
        E[1] += C.offset
    }
    return new Effect.Tween(null, B.top, E[1] > A ? A : E[1], C, function(F) {
        scrollTo(B.left, F.round())
    })
};
Effect.Fade = function(C) {
    C = $(C);
    var A = C.getInlineOpacity();
    var B = Object.extend({
        from: C.getOpacity() || 1,
        to: 0,
        afterFinishInternal: function(D) {
            if (D.options.to != 0) {
                return
            }
            D.element.hide().setStyle({
                opacity: A
            })
        }
    }, arguments[1] || {});
    return new Effect.Opacity(C, B)
};
Effect.Appear = function(B) {
    B = $(B);
    var A = Object.extend({
        from: (B.getStyle("display") == "none" ? 0 : B.getOpacity() || 0),
        to: 1,
        afterFinishInternal: function(C) {
            C.element.forceRerendering()
        },
        beforeSetup: function(C) {
            C.element.setOpacity(C.options.from).show()
        }
    }, arguments[1] || {});
    return new Effect.Opacity(B, A)
};
Effect.Puff = function(B) {
    B = $(B);
    var A = {
        opacity: B.getInlineOpacity(),
        position: B.getStyle("position"),
        top: B.style.top,
        left: B.style.left,
        width: B.style.width,
        height: B.style.height
    };
    return new Effect.Parallel([new Effect.Scale(B, 200, {
        sync: true,
        scaleFromCenter: true,
        scaleContent: true,
        restoreAfterFinish: true
    }), new Effect.Opacity(B, {
        sync: true,
        to: 0
    })], Object.extend({
        duration: 1,
        beforeSetupInternal: function(C) {
            Position.absolutize(C.effects[0].element)
        },
        afterFinishInternal: function(C) {
            C.effects[0].element.hide().setStyle(A)
        }
    }, arguments[1] || {}))
};
Effect.BlindUp = function(A) {
    A = $(A);
    A.makeClipping();
    return new Effect.Scale(A, 0, Object.extend({
        scaleContent: false,
        scaleX: false,
        restoreAfterFinish: true,
        afterFinishInternal: function(B) {
            B.element.hide().undoClipping()
        }
    }, arguments[1] || {}))
};
Effect.BlindDown = function(B) {
    B = $(B);
    var A = B.getDimensions();
    return new Effect.Scale(B, 100, Object.extend({
        scaleContent: false,
        scaleX: false,
        scaleFrom: 0,
        scaleMode: {
            originalHeight: A.height,
            originalWidth: A.width
        },
        restoreAfterFinish: true,
        afterSetup: function(C) {
            C.element.makeClipping().setStyle({
                height: "0px"
            }).show()
        },
        afterFinishInternal: function(C) {
            C.element.undoClipping()
        }
    }, arguments[1] || {}))
};
Effect.SwitchOff = function(B) {
    B = $(B);
    var A = B.getInlineOpacity();
    return new Effect.Appear(B, Object.extend({
        duration: 0.4,
        from: 0,
        transition: Effect.Transitions.flicker,
        afterFinishInternal: function(C) {
            new Effect.Scale(C.element, 1, {
                duration: 0.3,
                scaleFromCenter: true,
                scaleX: false,
                scaleContent: false,
                restoreAfterFinish: true,
                beforeSetup: function(D) {
                    D.element.makePositioned().makeClipping()
                },
                afterFinishInternal: function(D) {
                    D.element.hide().undoClipping().undoPositioned().setStyle({
                        opacity: A
                    })
                }
            })
        }
    }, arguments[1] || {}))
};
Effect.DropOut = function(B) {
    B = $(B);
    var A = {
        top: B.getStyle("top"),
        left: B.getStyle("left"),
        opacity: B.getInlineOpacity()
    };
    return new Effect.Parallel([new Effect.Move(B, {
        x: 0,
        y: 100,
        sync: true
    }), new Effect.Opacity(B, {
        sync: true,
        to: 0
    })], Object.extend({
        duration: 0.5,
        beforeSetup: function(C) {
            C.effects[0].element.makePositioned()
        },
        afterFinishInternal: function(C) {
            C.effects[0].element.hide().undoPositioned().setStyle(A)
        }
    }, arguments[1] || {}))
};
Effect.Shake = function(D) {
    D = $(D);
    var B = Object.extend({
        distance: 20,
        duration: 0.5
    }, arguments[1] || {});
    var E = parseFloat(B.distance);
    var C = parseFloat(B.duration) / 10;
    var A = {
        top: D.getStyle("top"),
        left: D.getStyle("left")
    };
    return new Effect.Move(D, {
        x: E,
        y: 0,
        duration: C,
        afterFinishInternal: function(F) {
            new Effect.Move(F.element, {
                x: -E * 2,
                y: 0,
                duration: C * 2,
                afterFinishInternal: function(G) {
                    new Effect.Move(G.element, {
                        x: E * 2,
                        y: 0,
                        duration: C * 2,
                        afterFinishInternal: function(H) {
                            new Effect.Move(H.element, {
                                x: -E * 2,
                                y: 0,
                                duration: C * 2,
                                afterFinishInternal: function(I) {
                                    new Effect.Move(I.element, {
                                        x: E * 2,
                                        y: 0,
                                        duration: C * 2,
                                        afterFinishInternal: function(J) {
                                            new Effect.Move(J.element, {
                                                x: -E,
                                                y: 0,
                                                duration: C,
                                                afterFinishInternal: function(K) {
                                                    K.element.undoPositioned().setStyle(A)
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }
    })
};
Effect.SlideDown = function(C) {
    C = $(C).cleanWhitespace();
    var A = C.down().getStyle("bottom");
    var B = C.getDimensions();
    return new Effect.Scale(C, 100, Object.extend({
        scaleContent: false,
        scaleX: false,
        scaleFrom: window.opera ? 0 : 1,
        scaleMode: {
            originalHeight: B.height,
            originalWidth: B.width
        },
        restoreAfterFinish: true,
        afterSetup: function(D) {
            D.element.makePositioned();
            D.element.down().makePositioned();
            if (window.opera) {
                D.element.setStyle({
                    top: ""
                })
            }
            D.element.makeClipping().setStyle({
                height: "0px"
            }).show()
        },
        afterUpdateInternal: function(D) {
            D.element.down().setStyle({
                bottom: (D.dims[0] - D.element.clientHeight) + "px"
            })
        },
        afterFinishInternal: function(D) {
            D.element.undoClipping().undoPositioned();
            D.element.down().undoPositioned().setStyle({
                bottom: A
            })
        }
    }, arguments[1] || {}))
};
Effect.SlideUp = function(C) {
    C = $(C).cleanWhitespace();
    var A = C.down().getStyle("bottom");
    var B = C.getDimensions();
    return new Effect.Scale(C, window.opera ? 0 : 1, Object.extend({
        scaleContent: false,
        scaleX: false,
        scaleMode: "box",
        scaleFrom: 100,
        scaleMode: {
            originalHeight: B.height,
            originalWidth: B.width
        },
        restoreAfterFinish: true,
        afterSetup: function(D) {
            D.element.makePositioned();
            D.element.down().makePositioned();
            if (window.opera) {
                D.element.setStyle({
                    top: ""
                })
            }
            D.element.makeClipping().show()
        },
        afterUpdateInternal: function(D) {
            D.element.down().setStyle({
                bottom: (D.dims[0] - D.element.clientHeight) + "px"
            })
        },
        afterFinishInternal: function(D) {
            D.element.hide().undoClipping().undoPositioned();
            D.element.down().undoPositioned().setStyle({
                bottom: A
            })
        }
    }, arguments[1] || {}))
};
Effect.Squish = function(A) {
    return new Effect.Scale(A, window.opera ? 1 : 0, {
        restoreAfterFinish: true,
        beforeSetup: function(B) {
            B.element.makeClipping()
        },
        afterFinishInternal: function(B) {
            B.element.hide().undoClipping()
        }
    })
};
Effect.Grow = function(C) {
    C = $(C);
    var B = Object.extend({
        direction: "center",
        moveTransition: Effect.Transitions.sinoidal,
        scaleTransition: Effect.Transitions.sinoidal,
        opacityTransition: Effect.Transitions.full
    }, arguments[1] || {});
    var A = {
        top: C.style.top,
        left: C.style.left,
        height: C.style.height,
        width: C.style.width,
        opacity: C.getInlineOpacity()
    };
    var G = C.getDimensions();
    var H, F;
    var E, D;
    switch (B.direction) {
    case "top-left":
        H = F = E = D = 0;
        break;
    case "top-right":
        H = G.width;
        F = D = 0;
        E = -G.width;
        break;
    case "bottom-left":
        H = E = 0;
        F = G.height;
        D = -G.height;
        break;
    case "bottom-right":
        H = G.width;
        F = G.height;
        E = -G.width;
        D = -G.height;
        break;
    case "center":
        H = G.width / 2;
        F = G.height / 2;
        E = -G.width / 2;
        D = -G.height / 2;
        break
    }
    return new Effect.Move(C, {
        x: H,
        y: F,
        duration: 0.01,
        beforeSetup: function(I) {
            I.element.hide().makeClipping().makePositioned()
        },
        afterFinishInternal: function(I) {
            new Effect.Parallel([new Effect.Opacity(I.element, {
                sync: true,
                to: 1,
                from: 0,
                transition: B.opacityTransition
            }), new Effect.Move(I.element, {
                x: E,
                y: D,
                sync: true,
                transition: B.moveTransition
            }), new Effect.Scale(I.element, 100, {
                scaleMode: {
                    originalHeight: G.height,
                    originalWidth: G.width
                },
                sync: true,
                scaleFrom: window.opera ? 1 : 0,
                transition: B.scaleTransition,
                restoreAfterFinish: true
            })], Object.extend({
                beforeSetup: function(J) {
                    J.effects[0].element.setStyle({
                        height: "0px"
                    }).show()
                },
                afterFinishInternal: function(J) {
                    J.effects[0].element.undoClipping().undoPositioned().setStyle(A)
                }
            }, B))
        }
    })
};
Effect.Shrink = function(C) {
    C = $(C);
    var B = Object.extend({
        direction: "center",
        moveTransition: Effect.Transitions.sinoidal,
        scaleTransition: Effect.Transitions.sinoidal,
        opacityTransition: Effect.Transitions.none
    }, arguments[1] || {});
    var A = {
        top: C.style.top,
        left: C.style.left,
        height: C.style.height,
        width: C.style.width,
        opacity: C.getInlineOpacity()
    };
    var F = C.getDimensions();
    var E, D;
    switch (B.direction) {
    case "top-left":
        E = D = 0;
        break;
    case "top-right":
        E = F.width;
        D = 0;
        break;
    case "bottom-left":
        E = 0;
        D = F.height;
        break;
    case "bottom-right":
        E = F.width;
        D = F.height;
        break;
    case "center":
        E = F.width / 2;
        D = F.height / 2;
        break
    }
    return new Effect.Parallel([new Effect.Opacity(C, {
        sync: true,
        to: 0,
        from: 1,
        transition: B.opacityTransition
    }), new Effect.Scale(C, window.opera ? 1 : 0, {
        sync: true,
        transition: B.scaleTransition,
        restoreAfterFinish: true
    }), new Effect.Move(C, {
        x: E,
        y: D,
        sync: true,
        transition: B.moveTransition
    })], Object.extend({
        beforeStartInternal: function(G) {
            G.effects[0].element.makePositioned().makeClipping()
        },
        afterFinishInternal: function(G) {
            G.effects[0].element.hide().undoClipping().undoPositioned().setStyle(A)
        }
    }, B))
};
Effect.Pulsate = function(C) {
    C = $(C);
    var B = arguments[1] || {};
    var A = C.getInlineOpacity();
    var E = B.transition || Effect.Transitions.sinoidal;
    var D = function(F) {
        return E(1 - Effect.Transitions.pulse(F, B.pulses))
    };
    D.bind(E);
    return new Effect.Opacity(C, Object.extend(Object.extend({
        duration: 2,
        from: 0,
        afterFinishInternal: function(F) {
            F.element.setStyle({
                opacity: A
            })
        }
    }, B), {
        transition: D
    }))
};
Effect.Fold = function(B) {
    B = $(B);
    var A = {
        top: B.style.top,
        left: B.style.left,
        width: B.style.width,
        height: B.style.height
    };
    B.makeClipping();
    return new Effect.Scale(B, 5, Object.extend({
        scaleContent: false,
        scaleX: false,
        afterFinishInternal: function(C) {
            new Effect.Scale(B, 1, {
                scaleContent: false,
                scaleY: false,
                afterFinishInternal: function(D) {
                    D.element.hide().undoClipping().setStyle(A)
                }
            })
        }
    }, arguments[1] || {}))
};
Effect.Morph = Class.create(Effect.Base, {
    initialize: function(C) {
        this.element = $(C);
        if (!this.element) {
            throw (Effect._elementDoesNotExistError)
        }
        var A = Object.extend({
            style: {}
        }, arguments[1] || {});
        if (!Object.isString(A.style)) {
            this.style = $H(A.style)
        } else {
            if (A.style.include(":")) {
                this.style = A.style.parseStyle()
            } else {
                this.element.addClassName(A.style);
                this.style = $H(this.element.getStyles());
                this.element.removeClassName(A.style);
                var B = this.element.getStyles();
                this.style = this.style.reject(function(D) {
                    return D.value == B[D.key]
                });
                A.afterFinishInternal = function(D) {
                    D.element.addClassName(D.options.style);
                    D.transforms.each(function(E) {
                        D.element.style[E.style] = ""
                    })
                }
            }
        }
        this.start(A)
    },
    setup: function() {
        function A(B) {
            if (!B || ["rgba(0, 0, 0, 0)", "transparent"].include(B)) {
                B = "#ffffff"
            }
            B = B.parseColor();
            return $R(0, 2).map(function(C) {
                return parseInt(B.slice(C * 2 + 1, C * 2 + 3), 16)
            })
        }
        this.transforms = this.style.map(function(G) {
            var F = G[0],
                E = G[1],
                D = null;
            if (E.parseColor("#zzzzzz") != "#zzzzzz") {
                E = E.parseColor();
                D = "color"
            } else {
                if (F == "opacity") {
                    E = parseFloat(E);
                    if (Prototype.Browser.IE && (!this.element.currentStyle.hasLayout)) {
                        this.element.setStyle({
                            zoom: 1
                        })
                    }
                } else {
                    if (Element.CSS_LENGTH.test(E)) {
                        var C = E.match(/^([\+\-]?[0-9\.]+)(.*)$/);
                        E = parseFloat(C[1]);
                        D = (C.length == 3) ? C[2] : null
                    }
                }
            }
            var B = this.element.getStyle(F);
            return {
                style: F.camelize(),
                originalValue: D == "color" ? A(B) : parseFloat(B || 0),
                targetValue: D == "color" ? A(E) : E,
                unit: D
            }
        }.bind(this)).reject(function(B) {
            return ((B.originalValue == B.targetValue) || (B.unit != "color" && (isNaN(B.originalValue) || isNaN(B.targetValue))))
        })
    },
    update: function(A) {
        var D = {},
            B, C = this.transforms.length;
        while (C--) {
            D[(B = this.transforms[C]).style] = B.unit == "color" ? "#" + (Math.round(B.originalValue[0] + (B.targetValue[0] - B.originalValue[0]) * A)).toColorPart() + (Math.round(B.originalValue[1] + (B.targetValue[1] - B.originalValue[1]) * A)).toColorPart() + (Math.round(B.originalValue[2] + (B.targetValue[2] - B.originalValue[2]) * A)).toColorPart() : (B.originalValue + (B.targetValue - B.originalValue) * A).toFixed(3) + (B.unit === null ? "" : B.unit)
        }
        this.element.setStyle(D, true)
    }
});
Effect.Transform = Class.create({
    initialize: function(A) {
        this.tracks = [];
        this.options = arguments[1] || {};
        this.addTracks(A)
    },
    addTracks: function(A) {
        A.each(function(B) {
            B = $H(B);
            var C = B.values().first();
            this.tracks.push($H({
                ids: B.keys().first(),
                effect: Effect.Morph,
                options: {
                    style: C
                }
            }))
        }.bind(this));
        return this
    },
    play: function() {
        return new Effect.Parallel(this.tracks.map(function(A) {
            var D = A.get("ids"),
                C = A.get("effect"),
                B = A.get("options");
            var E = [$(D) || $$(D)].flatten();
            return E.map(function(F) {
                return new C(F, Object.extend({
                    sync: true
                }, B))
            })
        }).flatten(), this.options)
    }
});
Element.CSS_PROPERTIES = $w("backgroundColor backgroundPosition borderBottomColor borderBottomStyle borderBottomWidth borderLeftColor borderLeftStyle borderLeftWidth borderRightColor borderRightStyle borderRightWidth borderSpacing borderTopColor borderTopStyle borderTopWidth bottom clip color fontSize fontWeight height left letterSpacing lineHeight marginBottom marginLeft marginRight marginTop markerOffset maxHeight maxWidth minHeight minWidth opacity outlineColor outlineOffset outlineWidth paddingBottom paddingLeft paddingRight paddingTop right textIndent top width wordSpacing zIndex");
Element.CSS_LENGTH = /^(([\+\-]?[0-9\.]+)(em|ex|px|in|cm|mm|pt|pc|\%))|0$/;
String.__parseStyleElement = document.createElement("div");
String.prototype.parseStyle = function() {
    var B, A = $H();
    if (Prototype.Browser.WebKit) {
        B = new Element("div", {
            style: this
        }).style
    } else {
        String.__parseStyleElement.innerHTML = '<div style="' + this + '"></div>';
        B = String.__parseStyleElement.childNodes[0].style
    }
    Element.CSS_PROPERTIES.each(function(C) {
        if (B[C]) {
            A.set(C, B[C])
        }
    });
    if (Prototype.Browser.IE && this.include("opacity")) {
        A.set("opacity", this.match(/opacity:\s*((?:0|1)?(?:\.\d*)?)/)[1])
    }
    return A
};
if (document.defaultView && document.defaultView.getComputedStyle) {
    Element.getStyles = function(B) {
        var A = document.defaultView.getComputedStyle($(B), null);
        return Element.CSS_PROPERTIES.inject({}, function(C, D) {
            C[D] = A[D];
            return C
        })
    }
} else {
    Element.getStyles = function(B) {
        B = $(B);
        var A = B.currentStyle,
            C;
        C = Element.CSS_PROPERTIES.inject({}, function(D, E) {
            D[E] = A[E];
            return D
        });
        if (!C.opacity) {
            C.opacity = B.getOpacity()
        }
        return C
    }
}
Effect.Methods = {
    morph: function(A, B) {
        A = $(A);
        new Effect.Morph(A, Object.extend({
            style: B
        }, arguments[2] || {}));
        return A
    },
    visualEffect: function(C, E, B) {
        C = $(C);
        var D = E.dasherize().camelize(),
            A = D.charAt(0).toUpperCase() + D.substring(1);
        new Effect[A](C, B);
        return C
    },
    highlight: function(B, A) {
        B = $(B);
        new Effect.Highlight(B, A);
        return B
    }
};
$w("fade appear grow shrink fold blindUp blindDown slideUp slideDown pulsate shake puff squish switchOff dropOut").each(function(A) {
    Effect.Methods[A] = function(C, B) {
        C = $(C);
        Effect[A.charAt(0).toUpperCase() + A.substring(1)](C, B);
        return C
    }
});
$w("getInlineOpacity forceRerendering setContentZoom collectTextNodes collectTextNodesIgnoreClass getStyles").each(function(A) {
    Effect.Methods[A] = Element[A]
});
Element.addMethods(Effect.Methods);
if (typeof Effect == "undefined") {
    throw ("controls.js requires including script.aculo.us' effects.js library")
}
var Autocompleter = {};
Autocompleter.Base = Class.create({
    baseInitialize: function(B, C, A) {
        B = $(B);
        this.element = B;
        this.update = $(C);
        this.hasFocus = false;
        this.changed = false;
        this.active = false;
        this.index = 0;
        this.entryCount = 0;
        this.oldElementValue = this.element.value;
        if (this.setOptions) {
            this.setOptions(A)
        } else {
            this.options = A || {}
        }
        this.options.paramName = this.options.paramName || this.element.name;
        this.options.tokens = this.options.tokens || [];
        this.options.frequency = this.options.frequency || 0.4;
        this.options.minChars = this.options.minChars || 1;
        this.options.onShow = this.options.onShow ||
        function(D, E) {
            if (!E.style.position || E.style.position == "absolute") {
                E.style.position = "absolute";
                Position.clone(D, E, {
                    setHeight: false,
                    offsetTop: D.offsetHeight
                })
            }
            Effect.Appear(E, {
                duration: 0.15
            })
        };
        this.options.onHide = this.options.onHide ||
        function(D, E) {
            new Effect.Fade(E, {
                duration: 0.15
            })
        };
        if (typeof(this.options.tokens) == "string") {
            this.options.tokens = new Array(this.options.tokens)
        }
        if (!this.options.tokens.include("\n")) {
            this.options.tokens.push("\n")
        }
        this.observer = null;
        this.element.setAttribute("autocomplete", "off");
        Element.hide(this.update);
        Event.observe(this.element, "blur", this.onBlur.bindAsEventListener(this));
        Event.observe(this.element, "keydown", this.onKeyPress.bindAsEventListener(this))
    },
    show: function() {
        if (Element.getStyle(this.update, "display") == "none") {
            this.options.onShow(this.element, this.update)
        }
        if (!this.iefix && (Prototype.Browser.IE) && (Element.getStyle(this.update, "position") == "absolute")) {
            new Insertion.After(this.update, '<iframe id="' + this.update.id + '_iefix" style="display:none;position:absolute;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);" src="javascript:false;" frameborder="0" scrolling="no"></iframe>');
            this.iefix = $(this.update.id + "_iefix")
        }
        if (this.iefix) {
            setTimeout(this.fixIEOverlapping.bind(this), 50)
        }
    },
    fixIEOverlapping: function() {
        Position.clone(this.update, this.iefix, {
            setTop: (!this.update.style.height)
        });
        this.iefix.style.zIndex = 1;
        this.update.style.zIndex = 2;
        Element.show(this.iefix)
    },
    hide: function() {
        this.stopIndicator();
        if (Element.getStyle(this.update, "display") != "none") {
            this.options.onHide(this.element, this.update)
        }
        if (this.iefix) {
            Element.hide(this.iefix)
        }
    },
    startIndicator: function() {
        if (this.options.indicator) {
            Element.show(this.options.indicator)
        }
    },
    stopIndicator: function() {
        if (this.options.indicator) {
            Element.hide(this.options.indicator)
        }
    },
    onKeyPress: function(A) {
        if (this.active) {
            switch (A.keyCode) {
            case Event.KEY_TAB:
            case Event.KEY_RETURN:
                this.selectEntry();
                Event.stop(A);
            case Event.KEY_ESC:
                this.hide();
                this.active = false;
                Event.stop(A);
                return;
            case Event.KEY_LEFT:
            case Event.KEY_RIGHT:
                return;
            case Event.KEY_UP:
                this.markPrevious();
                this.render();
                Event.stop(A);
                return;
            case Event.KEY_DOWN:
                this.markNext();
                this.render();
                Event.stop(A);
                return
            }
        } else {
            if (A.keyCode == Event.KEY_TAB || A.keyCode == Event.KEY_RETURN || (Prototype.Browser.WebKit > 0 && A.keyCode == 0)) {
                return
            }
        }
        this.changed = true;
        this.hasFocus = true;
        if (this.observer) {
            clearTimeout(this.observer)
        }
        this.observer = setTimeout(this.onObserverEvent.bind(this), this.options.frequency * 1000)
    },
    activate: function() {
        this.changed = false;
        this.hasFocus = true;
        this.getUpdatedChoices()
    },
    onHover: function(B) {
        var A = Event.findElement(B, "LI");
        if (this.index != A.autocompleteIndex) {
            this.index = A.autocompleteIndex;
            this.render()
        }
        Event.stop(B)
    },
    onClick: function(B) {
        var A = Event.findElement(B, "LI");
        this.index = A.autocompleteIndex;
        this.selectEntry();
        this.hide()
    },
    onBlur: function(A) {
        setTimeout(this.hide.bind(this), 250);
        this.hasFocus = false;
        this.active = false
    },
    render: function() {
        if (this.entryCount > 0) {
            for (var A = 0;
            A < this.entryCount; A++) {
                this.index == A ? Element.addClassName(this.getEntry(A), "selected") : Element.removeClassName(this.getEntry(A), "selected")
            }
            if (this.hasFocus) {
                this.show();
                this.active = true
            }
        } else {
            this.active = false;
            this.hide()
        }
    },
    markPrevious: function() {
        if (this.index > 0) {
            this.index--
        } else {
            this.index = this.entryCount - 1
        }
        this.ensureSelectedVisible()
    },
    markNext: function() {
        if (this.index < this.entryCount - 1) {
            this.index++
        } else {
            this.index = 0
        }
        this.ensureSelectedVisible()
    },
    ensureSelectedVisible: function() {
        var C = this.getEntry(this.index);
        var F = new Element.Layout(C);
        var G = F.get("top");
        var B = G + F.get("margin-box-height");
        var A = new Element.Layout(this.update);
        var D = G - A.get("padding-top");
        var E = B - A.get("height") - A.get("padding-bottom");
        if (this.update.scrollTop > D) {
            this.update.scrollTop = D
        } else {
            if (this.update.scrollTop < E) {
                this.update.scrollTop = E
            }
        }
    },
    getEntry: function(A) {
        return this.update.firstChild.childNodes[A]
    },
    getCurrentEntry: function() {
        return this.getEntry(this.index)
    },
    selectEntry: function() {
        this.active = false;
        this.updateElement(this.getCurrentEntry())
    },
    updateElement: function(F) {
        if (this.options.updateElement) {
            this.options.updateElement(F);
            return
        }
        var D = "";
        if (this.options.select) {
            var A = $(F).select("." + this.options.select) || [];
            if (A.length > 0) {
                D = Element.collectTextNodes(A[0], this.options.select)
            }
        } else {
            D = Element.collectTextNodesIgnoreClass(F, "informal")
        }
        var C = this.getTokenBounds();
        if (C[0] != -1) {
            var E = this.element.value.substr(0, C[0]);
            var B = this.element.value.substr(C[0]).match(/^\s+/);
            if (B) {
                E += B[0]
            }
            this.element.value = E + D + this.element.value.substr(C[1])
        } else {
            this.element.value = D
        }
        this.oldElementValue = this.element.value;
        this.element.focus();
        if (this.options.afterUpdateElement) {
            this.options.afterUpdateElement(this.element, F)
        }
    },
    updateChoices: function(C) {
        if (!this.changed && this.hasFocus) {
            this.update.innerHTML = C;
            Element.cleanWhitespace(this.update);
            Element.cleanWhitespace(this.update.down());
            if (this.update.firstChild && this.update.down().childNodes) {
                this.entryCount = this.update.down().childNodes.length;
                for (var A = 0; A < this.entryCount; A++) {
                    var B = this.getEntry(A);
                    B.autocompleteIndex = A;
                    this.addObservers(B)
                }
            } else {
                this.entryCount = 0
            }
            this.stopIndicator();
            this.update.scrollTop = 0;
            this.index = 0;
            if (this.entryCount == 1 && this.options.autoSelect) {
                this.selectEntry();
                this.hide()
            } else {
                this.render()
            }
        }
    },
    addObservers: function(A) {
        Event.observe(A, "mouseover", this.onHover.bindAsEventListener(this));
        Event.observe(A, "click", this.onClick.bindAsEventListener(this))
    },
    onObserverEvent: function() {
        this.changed = false;
        this.tokenBounds = null;
        if (this.getToken().length >= this.options.minChars) {
            this.getUpdatedChoices()
        } else {
            this.active = false;
            this.hide()
        }
        this.oldElementValue = this.element.value
    },
    getToken: function() {
        var A = this.getTokenBounds();
        return this.element.value.substring(A[0], A[1]).strip()
    },
    getTokenBounds: function() {
        if (null != this.tokenBounds) {
            return this.tokenBounds
        }
        var E = this.element.value;
        if (E.strip().empty()) {
            return [-1, 0]
        }
        var F = arguments.callee.getFirstDifferencePos(E, this.oldElementValue);
        var H = (F == this.oldElementValue.length ? 1 : 0);
        var D = -1,
            C = E.length;
        var G;
        for (var B = 0, A = this.options.tokens.length;
        B < A; ++B) {
            G = E.lastIndexOf(this.options.tokens[B], F + H - 1);
            if (G > D) {
                D = G
            }
            G = E.indexOf(this.options.tokens[B], F + H);
            if (-1 != G && G < C) {
                C = G
            }
        }
        return (this.tokenBounds = [D + 1, C])
    }
});
Autocompleter.Base.prototype.getTokenBounds.getFirstDifferencePos = function(C, A) {
    var D = Math.min(C.length, A.length);
    for (var B = 0; B < D; ++B) {
        if (C[B] != A[B]) {
            return B
        }
    }
    return D
};
Ajax.Autocompleter = Class.create(Autocompleter.Base, {
    initialize: function(C, D, B, A) {
        this.baseInitialize(C, D, A);
        this.options.asynchronous = true;
        this.options.onComplete = this.onComplete.bind(this);
        this.options.defaultParams = this.options.parameters || null;
        this.url = B
    },
    getUpdatedChoices: function() {
        this.startIndicator();
        var A = encodeURIComponent(this.options.paramName) + "=" + encodeURIComponent(this.getToken());
        this.options.parameters = this.options.callback ? this.options.callback(this.element, A) : A;
        if (this.options.defaultParams) {
            this.options.parameters += "&" + this.options.defaultParams
        }
        new Ajax.Request(this.url, this.options)
    },
    onComplete: function(A) {
        this.updateChoices(A.responseText)
    }
});
Autocompleter.Local = Class.create(Autocompleter.Base, {
    initialize: function(B, D, C, A) {
        this.baseInitialize(B, D, A);
        this.options.array = C
    },
    getUpdatedChoices: function() {
        this.updateChoices(this.options.selector(this))
    },
    setOptions: function(A) {
        this.options = Object.extend({
            choices: 10,
            partialSearch: true,
            partialChars: 2,
            ignoreCase: true,
            fullSearch: false,
            selector: function(B) {
                var D = [];
                var C = [];
                var H = B.getToken();
                var G = 0;
                for (var E = 0; E < B.options.array.length && D.length < B.options.choices;
                E++) {
                    var F = B.options.array[E];
                    var I = B.options.ignoreCase ? F.toLowerCase().indexOf(H.toLowerCase()) : F.indexOf(H);
                    while (I != -1) {
                        if (I == 0 && F.length != H.length) {
                            D.push("<li><strong>" + F.substr(0, H.length) + "</strong>" + F.substr(H.length) + "</li>");
                            break
                        } else {
                            if (H.length >= B.options.partialChars && B.options.partialSearch && I != -1) {
                                if (B.options.fullSearch || /\s/.test(F.substr(I - 1, 1))) {
                                    C.push("<li>" + F.substr(0, I) + "<strong>" + F.substr(I, H.length) + "</strong>" + F.substr(I + H.length) + "</li>");
                                    break
                                }
                            }
                        }
                        I = B.options.ignoreCase ? F.toLowerCase().indexOf(H.toLowerCase(), I + 1) : F.indexOf(H, I + 1)
                    }
                }
                if (C.length) {
                    D = D.concat(C.slice(0, B.options.choices - D.length))
                }
                return "<ul>" + D.join("") + "</ul>"
            }
        }, A || {})
    }
});
Field.scrollFreeActivate = function(A) {
    setTimeout(function() {
        Field.activate(A)
    }, 1)
};
Ajax.InPlaceEditor = Class.create({
    initialize: function(C, B, A) {
        this.url = B;
        this.element = C = $(C);
        this.prepareOptions();
        this._controls = {};
        arguments.callee.dealWithDeprecatedOptions(A);
        Object.extend(this.options, A || {});
        if (!this.options.formId && this.element.id) {
            this.options.formId = this.element.id + "-inplaceeditor";
            if ($(this.options.formId)) {
                this.options.formId = ""
            }
        }
        if (this.options.externalControl) {
            this.options.externalControl = $(this.options.externalControl)
        }
        if (!this.options.externalControl) {
            this.options.externalControlOnly = false
        }
        this._originalBackground = this.element.getStyle("background-color") || "transparent";
        this.element.title = this.options.clickToEditText;
        this._boundCancelHandler = this.handleFormCancellation.bind(this);
        this._boundComplete = (this.options.onComplete || Prototype.emptyFunction).bind(this);
        this._boundFailureHandler = this.handleAJAXFailure.bind(this);
        this._boundSubmitHandler = this.handleFormSubmission.bind(this);
        this._boundWrapperHandler = this.wrapUp.bind(this);
        this.registerListeners()
    },
    checkForEscapeOrReturn: function(A) {
        if (!this._editing || A.ctrlKey || A.altKey || A.shiftKey) {
            return
        }
        if (Event.KEY_ESC == A.keyCode) {
            this.handleFormCancellation(A)
        } else {
            if (Event.KEY_RETURN == A.keyCode) {
                this.handleFormSubmission(A)
            }
        }
    },
    createControl: function(G, C, B) {
        var E = this.options[G + "Control"];
        var F = this.options[G + "Text"];
        if ("button" == E) {
            var A = document.createElement("input");
            A.type = "submit";
            A.value = F;
            A.className = "editor_" + G + "_button";
            if ("cancel" == G) {
                A.onclick = this._boundCancelHandler
            }
            this._form.appendChild(A);
            this._controls[G] = A
        } else {
            if ("link" == E) {
                var D = document.createElement("a");
                D.href = "#";
                D.appendChild(document.createTextNode(F));
                D.onclick = "cancel" == G ? this._boundCancelHandler : this._boundSubmitHandler;
                D.className = "editor_" + G + "_link";
                if (B) {
                    D.className += " " + B
                }
                this._form.appendChild(D);
                this._controls[G] = D
            }
        }
    },
    createEditField: function() {
        var C = (this.options.loadTextURL ? this.options.loadingText : this.getText());
        var B;
        if (1 >= this.options.rows && !/\r|\n/.test(this.getText())) {
            B = document.createElement("input");
            B.type = "text";
            var A = this.options.size || this.options.cols || 0;
            if (0 < A) {
                B.size = A
            }
        } else {
            B = document.createElement("textarea");
            B.rows = (1 >= this.options.rows ? this.options.autoRows : this.options.rows);
            B.cols = this.options.cols || 40
        }
        B.name = this.options.paramName;
        B.value = C;
        B.className = "editor_field";
        if (this.options.submitOnBlur) {
            B.onblur = this._boundSubmitHandler
        }
        this._controls.editor = B;
        if (this.options.loadTextURL) {
            this.loadExternalText()
        }
        this._form.appendChild(this._controls.editor)
    },
    createForm: function() {
        var B = this;

        function A(D, E) {
            var C = B.options["text" + D + "Controls"];
            if (!C || E === false) {
                return
            }
            B._form.appendChild(document.createTextNode(C))
        }
        this._form = $(document.createElement("form"));
        this._form.id = this.options.formId;
        this._form.addClassName(this.options.formClassName);
        this._form.onsubmit = this._boundSubmitHandler;
        this.createEditField();
        if ("textarea" == this._controls.editor.tagName.toLowerCase()) {
            this._form.appendChild(document.createElement("br"))
        }
        if (this.options.onFormCustomization) {
            this.options.onFormCustomization(this, this._form)
        }
        A("Before", this.options.okControl || this.options.cancelControl);
        this.createControl("ok", this._boundSubmitHandler);
        A("Between", this.options.okControl && this.options.cancelControl);
        this.createControl("cancel", this._boundCancelHandler, "editor_cancel");
        A("After", this.options.okControl || this.options.cancelControl)
    },
    destroy: function() {
        if (this._oldInnerHTML) {
            this.element.innerHTML = this._oldInnerHTML
        }
        this.leaveEditMode();
        this.unregisterListeners()
    },
    enterEditMode: function(A) {
        if (this._saving || this._editing) {
            return
        }
        this._editing = true;
        this.triggerCallback("onEnterEditMode");
        if (this.options.externalControl) {
            this.options.externalControl.hide()
        }
        this.element.hide();
        this.createForm();
        this.element.parentNode.insertBefore(this._form, this.element);
        if (!this.options.loadTextURL) {
            this.postProcessEditField()
        }
        if (A) {
            Event.stop(A)
        }
    },
    enterHover: function(A) {
        if (this.options.hoverClassName) {
            this.element.addClassName(this.options.hoverClassName)
        }
        if (this._saving) {
            return
        }
        this.triggerCallback("onEnterHover")
    },
    getText: function() {
        return this.element.innerHTML
    },
    handleAJAXFailure: function(A) {
        this.triggerCallback("onFailure", A);
        if (this._oldInnerHTML) {
            this.element.innerHTML = this._oldInnerHTML;
            this._oldInnerHTML = null
        }
    },
    handleFormCancellation: function(A) {
        this.wrapUp();
        if (A) {
            Event.stop(A)
        }
    },
    handleFormSubmission: function(D) {
        var B = this._form;
        var C = $F(this._controls.editor);
        this.prepareSubmission();
        var E = this.options.callback(B, C) || "";
        if (Object.isString(E)) {
            E = E.toQueryParams()
        }
        E.editorId = this.element.id;
        if (this.options.htmlResponse) {
            var A = Object.extend({
                evalScripts: true
            }, this.options.ajaxOptions);
            Object.extend(A, {
                parameters: E,
                onComplete: this._boundWrapperHandler,
                onFailure: this._boundFailureHandler
            });
            new Ajax.Updater({
                success: this.element
            }, this.url, A)
        } else {
            var A = Object.extend({
                method: "get"
            }, this.options.ajaxOptions);
            Object.extend(A, {
                parameters: E,
                onComplete: this._boundWrapperHandler,
                onFailure: this._boundFailureHandler
            });
            new Ajax.Request(this.url, A)
        }
        if (D) {
            Event.stop(D)
        }
    },
    leaveEditMode: function() {
        this.element.removeClassName(this.options.savingClassName);
        this.removeForm();
        this.leaveHover();
        this.element.style.backgroundColor = this._originalBackground;
        this.element.show();
        if (this.options.externalControl) {
            this.options.externalControl.show()
        }
        this._saving = false;
        this._editing = false;
        this._oldInnerHTML = null;
        this.triggerCallback("onLeaveEditMode")
    },
    leaveHover: function(A) {
        if (this.options.hoverClassName) {
            this.element.removeClassName(this.options.hoverClassName)
        }
        if (this._saving) {
            return
        }
        this.triggerCallback("onLeaveHover")
    },
    loadExternalText: function() {
        this._form.addClassName(this.options.loadingClassName);
        this._controls.editor.disabled = true;
        var A = Object.extend({
            method: "get"
        }, this.options.ajaxOptions);
        Object.extend(A, {
            parameters: "editorId=" + encodeURIComponent(this.element.id),
            onComplete: Prototype.emptyFunction,
            onSuccess: function(C) {
                this._form.removeClassName(this.options.loadingClassName);
                var B = C.responseText;
                if (this.options.stripLoadedTextTags) {
                    B = B.stripTags()
                }
                this._controls.editor.value = B;
                this._controls.editor.disabled = false;
                this.postProcessEditField()
            }.bind(this),
            onFailure: this._boundFailureHandler
        });
        new Ajax.Request(this.options.loadTextURL, A)
    },
    postProcessEditField: function() {
        var A = this.options.fieldPostCreation;
        if (A) {
            $(this._controls.editor)["focus" == A ? "focus" : "activate"]()
        }
    },
    prepareOptions: function() {
        this.options = Object.clone(Ajax.InPlaceEditor.DefaultOptions);
        Object.extend(this.options, Ajax.InPlaceEditor.DefaultCallbacks);
        [this._extraDefaultOptions].flatten().compact().each(function(A) {
            Object.extend(this.options, A)
        }.bind(this))
    },
    prepareSubmission: function() {
        this._saving = true;
        this.removeForm();
        this.leaveHover();
        this.showSaving()
    },
    registerListeners: function() {
        this._listeners = {};
        var A;
        $H(Ajax.InPlaceEditor.Listeners).each(function(B) {
            A = this[B.value].bind(this);
            this._listeners[B.key] = A;
            if (!this.options.externalControlOnly) {
                this.element.observe(B.key, A)
            }
            if (this.options.externalControl) {
                this.options.externalControl.observe(B.key, A)
            }
        }.bind(this))
    },
    removeForm: function() {
        if (!this._form) {
            return
        }
        this._form.remove();
        this._form = null;
        this._controls = {}
    },
    showSaving: function() {
        this._oldInnerHTML = this.element.innerHTML;
        this.element.innerHTML = this.options.savingText;
        this.element.addClassName(this.options.savingClassName);
        this.element.style.backgroundColor = this._originalBackground;
        this.element.show()
    },
    triggerCallback: function(B, A) {
        if ("function" == typeof this.options[B]) {
            this.options[B](this, A)
        }
    },
    unregisterListeners: function() {
        $H(this._listeners).each(function(A) {
            if (!this.options.externalControlOnly) {
                this.element.stopObserving(A.key, A.value)
            }
            if (this.options.externalControl) {
                this.options.externalControl.stopObserving(A.key, A.value)
            }
        }.bind(this))
    },
    wrapUp: function(A) {
        this.leaveEditMode();
        this._boundComplete(A, this.element)
    }
});
Object.extend(Ajax.InPlaceEditor.prototype, {
    dispose: Ajax.InPlaceEditor.prototype.destroy
});
Ajax.InPlaceCollectionEditor = Class.create(Ajax.InPlaceEditor, {
    initialize: function($super, C, B, A) {
        this._extraDefaultOptions = Ajax.InPlaceCollectionEditor.DefaultOptions;
        $super(C, B, A)
    },
    createEditField: function() {
        var A = document.createElement("select");
        A.name = this.options.paramName;
        A.size = 1;
        this._controls.editor = A;
        this._collection = this.options.collection || [];
        if (this.options.loadCollectionURL) {
            this.loadCollection()
        } else {
            this.checkForExternalText()
        }
        this._form.appendChild(this._controls.editor)
    },
    loadCollection: function() {
        this._form.addClassName(this.options.loadingClassName);
        this.showLoadingText(this.options.loadingCollectionText);
        var options = Object.extend({
            method: "get"
        }, this.options.ajaxOptions);
        Object.extend(options, {
            parameters: "editorId=" + encodeURIComponent(this.element.id),
            onComplete: Prototype.emptyFunction,
            onSuccess: function(transport) {
                var js = transport.responseText.strip();
                if (!/^\[.*\]$/.test(js)) {
                    throw "Server returned an invalid collection representation."
                }
                this._collection = eval(js);
                this.checkForExternalText()
            }.bind(this),
            onFailure: this.onFailure
        });
        new Ajax.Request(this.options.loadCollectionURL, options)
    },
    showLoadingText: function(B) {
        this._controls.editor.disabled = true;
        var A = this._controls.editor.firstChild;
        if (!A) {
            A = document.createElement("option");
            A.value = "";
            this._controls.editor.appendChild(A);
            A.selected = true
        }
        A.update((B || "").stripScripts().stripTags())
    },
    checkForExternalText: function() {
        this._text = this.getText();
        if (this.options.loadTextURL) {
            this.loadExternalText()
        } else {
            this.buildOptionList()
        }
    },
    loadExternalText: function() {
        this.showLoadingText(this.options.loadingText);
        var A = Object.extend({
            method: "get"
        }, this.options.ajaxOptions);
        Object.extend(A, {
            parameters: "editorId=" + encodeURIComponent(this.element.id),
            onComplete: Prototype.emptyFunction,
            onSuccess: function(B) {
                this._text = B.responseText.strip();
                this.buildOptionList()
            }.bind(this),
            onFailure: this.onFailure
        });
        new Ajax.Request(this.options.loadTextURL, A)
    },
    buildOptionList: function() {
        this._form.removeClassName(this.options.loadingClassName);
        this._collection = this._collection.map(function(D) {
            return 2 === D.length ? D : [D, D].flatten()
        });
        var B = ("value" in this.options) ? this.options.value : this._text;
        var A = this._collection.any(function(D) {
            return D[0] == B
        }.bind(this));
        this._controls.editor.update("");
        var C;
        this._collection.each(function(E, D) {
            C = document.createElement("option");
            C.value = E[0];
            C.selected = A ? E[0] == B : 0 == D;
            C.appendChild(document.createTextNode(E[1]));
            this._controls.editor.appendChild(C)
        }.bind(this));
        this._controls.editor.disabled = false;
        Field.scrollFreeActivate(this._controls.editor)
    }
});
Ajax.InPlaceEditor.prototype.initialize.dealWithDeprecatedOptions = function(A) {
    if (!A) {
        return
    }
    function B(C, D) {
        if (C in A || D === undefined) {
            return
        }
        A[C] = D
    }
    B("cancelControl", (A.cancelLink ? "link" : (A.cancelButton ? "button" : A.cancelLink == A.cancelButton == false ? false : undefined)));
    B("okControl", (A.okLink ? "link" : (A.okButton ? "button" : A.okLink == A.okButton == false ? false : undefined)));
    B("highlightColor", A.highlightcolor);
    B("highlightEndColor", A.highlightendcolor)
};
Object.extend(Ajax.InPlaceEditor, {
    DefaultOptions: {
        ajaxOptions: {},
        autoRows: 3,
        cancelControl: "link",
        cancelText: "cancel",
        clickToEditText: "Click to edit",
        externalControl: null,
        externalControlOnly: false,
        fieldPostCreation: "activate",
        formClassName: "inplaceeditor-form",
        formId: null,
        highlightColor: "#ffff99",
        highlightEndColor: "#ffffff",
        hoverClassName: "",
        htmlResponse: true,
        loadingClassName: "inplaceeditor-loading",
        loadingText: "Loading...",
        okControl: "button",
        okText: "ok",
        paramName: "value",
        rows: 1,
        savingClassName: "inplaceeditor-saving",
        savingText: "Saving...",
        size: 0,
        stripLoadedTextTags: false,
        submitOnBlur: false,
        textAfterControls: "",
        textBeforeControls: "",
        textBetweenControls: ""
    },
    DefaultCallbacks: {
        callback: function(A) {
            return Form.serialize(A)
        },
        onComplete: function(B, A) {
            new Effect.Highlight(A, {
                startcolor: this.options.highlightColor,
                keepBackgroundImage: true
            })
        },
        onEnterEditMode: null,
        onEnterHover: function(A) {
            A.element.style.backgroundColor = A.options.highlightColor;
            if (A._effect) {
                A._effect.cancel()
            }
        },
        onFailure: function(B, A) {
            alert("Error communication with the server: " + B.responseText.stripTags())
        },
        onFormCustomization: null,
        onLeaveEditMode: null,
        onLeaveHover: function(A) {
            A._effect = new Effect.Highlight(A.element, {
                startcolor: A.options.highlightColor,
                endcolor: A.options.highlightEndColor,
                restorecolor: A._originalBackground,
                keepBackgroundImage: true
            })
        }
    },
    Listeners: {
        click: "enterEditMode",
        keydown: "checkForEscapeOrReturn",
        mouseover: "enterHover",
        mouseout: "leaveHover"
    }
});
Ajax.InPlaceCollectionEditor.DefaultOptions = {
    loadingCollectionText: "Loading options..."
};
Form.Element.DelayedObserver = Class.create({
    initialize: function(B, A, C) {
        this.delay = A || 0.5;
        this.element = $(B);
        this.callback = C;
        this.timer = null;
        this.lastValue = $F(this.element);
        Event.observe(this.element, "keyup", this.delayedListener.bindAsEventListener(this))
    },
    delayedListener: function(A) {
        if (this.lastValue == $F(this.element)) {
            return
        }
        if (this.timer) {
            clearTimeout(this.timer)
        }
        this.timer = setTimeout(this.onTimerEvent.bind(this), this.delay * 1000);
        this.lastValue = $F(this.element)
    },
    onTimerEvent: function() {
        this.timer = null;
        this.callback(this.element, $F(this.element))
    }
});
if (Object.isUndefined(Effect)) {
    throw ("dragdrop.js requires including script.aculo.us' effects.js library")
}
var Droppables = {
    drops: [],
    remove: function(A) {
        this.drops = this.drops.reject(function(B) {
            return B.element == $(A)
        })
    },
    add: function(B) {
        B = $(B);
        var A = Object.extend({
            greedy: true,
            hoverclass: null,
            tree: false
        }, arguments[1] || {});
        if (A.containment) {
            A._containers = [];
            var C = A.containment;
            if (Object.isArray(C)) {
                C.each(function(D) {
                    A._containers.push($(D))
                })
            } else {
                A._containers.push($(C))
            }
        }
        if (A.accept) {
            A.accept = [A.accept].flatten()
        }
        Element.makePositioned(B);
        A.element = B;
        this.drops.push(A)
    },
    findDeepestChild: function(A) {
        deepest = A[0];
        for (i = 1;
        i < A.length; ++i) {
            if (Element.isParent(A[i].element, deepest.element)) {
                deepest = A[i]
            }
        }
        return deepest
    },
    isContained: function(B, A) {
        var C;
        if (A.tree) {
            C = B.treeNode
        } else {
            C = B.parentNode
        }
        return A._containers.detect(function(D) {
            return C == D
        })
    },
    isAffected: function(A, C, B) {
        return ((B.element != C) && ((!B._containers) || this.isContained(C, B)) && ((!B.accept) || (Element.classNames(C).detect(function(D) {
            return B.accept.include(D)
        }))) && Position.within(B.element, A[0], A[1]))
    },
    deactivate: function(A) {
        if (A.hoverclass) {
            Element.removeClassName(A.element, A.hoverclass)
        }
        this.last_active = null
    },
    activate: function(A) {
        if (A.hoverclass) {
            Element.addClassName(A.element, A.hoverclass)
        }
        this.last_active = A
    },
    show: function(A, C) {
        if (!this.drops.length) {
            return
        }
        var B, D = [];
        this.drops.each(function(E) {
            if (Droppables.isAffected(A, C, E)) {
                D.push(E)
            }
        });
        if (D.length > 0) {
            B = Droppables.findDeepestChild(D)
        }
        if (this.last_active && this.last_active != B) {
            this.deactivate(this.last_active)
        }
        if (B) {
            Position.within(B.element, A[0], A[1]);
            if (B.onHover) {
                B.onHover(C, B.element, Position.overlap(B.overlap, B.element))
            }
            if (B != this.last_active) {
                Droppables.activate(B)
            }
        }
    },
    fire: function(B, A) {
        if (!this.last_active) {
            return
        }
        Position.prepare();
        if (this.isAffected([Event.pointerX(B), Event.pointerY(B)], A, this.last_active)) {
            if (this.last_active.onDrop) {
                this.last_active.onDrop(A, this.last_active.element, B);
                return true
            }
        }
    },
    reset: function() {
        if (this.last_active) {
            this.deactivate(this.last_active)
        }
    }
};
var Draggables = {
    drags: [],
    observers: [],
    register: function(A) {
        if (this.drags.length == 0) {
            this.eventMouseUp = this.endDrag.bindAsEventListener(this);
            this.eventMouseMove = this.updateDrag.bindAsEventListener(this);
            this.eventKeypress = this.keyPress.bindAsEventListener(this);
            Event.observe(document, "mouseup", this.eventMouseUp);
            Event.observe(document, "mousemove", this.eventMouseMove);
            Event.observe(document, "keypress", this.eventKeypress)
        }
        this.drags.push(A)
    },
    unregister: function(A) {
        this.drags = this.drags.reject(function(B) {
            return B == A
        });
        if (this.drags.length == 0) {
            Event.stopObserving(document, "mouseup", this.eventMouseUp);
            Event.stopObserving(document, "mousemove", this.eventMouseMove);
            Event.stopObserving(document, "keypress", this.eventKeypress)
        }
    },
    activate: function(A) {
        if (A.options.delay) {
            this._timeout = setTimeout(function() {
                Draggables._timeout = null;
                window.focus();
                Draggables.activeDraggable = A
            }.bind(this), A.options.delay)
        } else {
            window.focus();
            this.activeDraggable = A
        }
    },
    deactivate: function() {
        this.activeDraggable = null
    },
    updateDrag: function(A) {
        if (!this.activeDraggable) {
            return
        }
        var B = [Event.pointerX(A), Event.pointerY(A)];
        if (this._lastPointer && (this._lastPointer.inspect() == B.inspect())) {
            return
        }
        this._lastPointer = B;
        this.activeDraggable.updateDrag(A, B)
    },
    endDrag: function(A) {
        if (this._timeout) {
            clearTimeout(this._timeout);
            this._timeout = null
        }
        if (!this.activeDraggable) {
            return
        }
        this._lastPointer = null;
        this.activeDraggable.endDrag(A);
        this.activeDraggable = null
    },
    keyPress: function(A) {
        if (this.activeDraggable) {
            this.activeDraggable.keyPress(A)
        }
    },
    addObserver: function(A) {
        this.observers.push(A);
        this._cacheObserverCallbacks()
    },
    removeObserver: function(A) {
        this.observers = this.observers.reject(function(B) {
            return B.element == A
        });
        this._cacheObserverCallbacks()
    },
    notify: function(B, A, C) {
        if (this[B + "Count"] > 0) {
            this.observers.each(function(D) {
                if (D[B]) {
                    D[B](B, A, C)
                }
            })
        }
        if (A.options[B]) {
            A.options[B](A, C)
        }
    },
    _cacheObserverCallbacks: function() {
        ["onStart", "onEnd", "onDrag"].each(function(A) {
            Draggables[A + "Count"] = Draggables.observers.select(function(B) {
                return B[A]
            }).length
        })
    }
};
var Draggable = Class.create({
    initialize: function(B) {
        var C = {
            handle: false,
            reverteffect: function(F, E, D) {
                var G = Math.sqrt(Math.abs(E ^ 2) + Math.abs(D ^ 2)) * 0.02;
                new Effect.Move(F, {
                    x: -D,
                    y: -E,
                    duration: G,
                    queue: {
                        scope: "_draggable",
                        position: "end"
                    }
                })
            },
            endeffect: function(E) {
                var D = Object.isNumber(E._opacity) ? E._opacity : 1;
                new Effect.Opacity(E, {
                    duration: 0.2,
                    from: 0.7,
                    to: D,
                    queue: {
                        scope: "_draggable",
                        position: "end"
                    },
                    afterFinish: function() {
                        Draggable._dragging[E] = false
                    }
                })
            },
            zindex: 1000,
            revert: false,
            quiet: false,
            scroll: false,
            scrollSensitivity: 20,
            scrollSpeed: 15,
            snap: false,
            delay: 0
        };
        if (!arguments[1] || Object.isUndefined(arguments[1].endeffect)) {
            Object.extend(C, {
                starteffect: function(D) {
                    D._opacity = Element.getOpacity(D);
                    Draggable._dragging[D] = true;
                    new Effect.Opacity(D, {
                        duration: 0.2,
                        from: D._opacity,
                        to: 0.7
                    })
                }
            })
        }
        var A = Object.extend(C, arguments[1] || {});
        this.element = $(B);
        if (A.handle && Object.isString(A.handle)) {
            this.handle = this.element.down("." + A.handle, 0)
        }
        if (!this.handle) {
            this.handle = $(A.handle)
        }
        if (!this.handle) {
            this.handle = this.element
        }
        if (A.scroll && !A.scroll.scrollTo && !A.scroll.outerHTML) {
            A.scroll = $(A.scroll);
            this._isScrollChild = Element.childOf(this.element, A.scroll)
        }
        Element.makePositioned(this.element);
        this.options = A;
        this.dragging = false;
        this.eventMouseDown = this.initDrag.bindAsEventListener(this);
        Event.observe(this.handle, "mousedown", this.eventMouseDown);
        Draggables.register(this)
    },
    destroy: function() {
        Event.stopObserving(this.handle, "mousedown", this.eventMouseDown);
        Draggables.unregister(this)
    },
    currentDelta: function() {
        return ([parseInt(Element.getStyle(this.element, "left") || "0"), parseInt(Element.getStyle(this.element, "top") || "0")])
    },
    initDrag: function(A) {
        if (!Object.isUndefined(Draggable._dragging[this.element]) && Draggable._dragging[this.element]) {
            return
        }
        if (Event.isLeftClick(A)) {
            var C = Event.element(A);
            if ((tag_name = C.tagName.toUpperCase()) && (tag_name == "INPUT" || tag_name == "SELECT" || tag_name == "OPTION" || tag_name == "BUTTON" || tag_name == "TEXTAREA")) {
                return
            }
            var B = [Event.pointerX(A), Event.pointerY(A)];
            var D = Position.cumulativeOffset(this.element);
            this.offset = [0, 1].map(function(E) {
                return (B[E] - D[E])
            });
            Draggables.activate(this);
            Event.stop(A)
        }
    },
    startDrag: function(B) {
        this.dragging = true;
        if (!this.delta) {
            this.delta = this.currentDelta()
        }
        if (this.options.zindex) {
            this.originalZ = parseInt(Element.getStyle(this.element, "z-index") || 0);
            this.element.style.zIndex = this.options.zindex
        }
        if (this.options.ghosting) {
            this._clone = this.element.cloneNode(true);
            this.element._originallyAbsolute = (this.element.getStyle("position") == "absolute");
            if (!this.element._originallyAbsolute) {
                Position.absolutize(this.element)
            }
            this.element.parentNode.insertBefore(this._clone, this.element)
        }
        if (this.options.scroll) {
            if (this.options.scroll == window) {
                var A = this._getWindowScroll(this.options.scroll);
                this.originalScrollLeft = A.left;
                this.originalScrollTop = A.top
            } else {
                this.originalScrollLeft = this.options.scroll.scrollLeft;
                this.originalScrollTop = this.options.scroll.scrollTop
            }
        }
        Draggables.notify("onStart", this, B);
        if (this.options.starteffect) {
            this.options.starteffect(this.element)
        }
    },
    updateDrag: function(event, pointer) {
        if (!this.dragging) {
            this.startDrag(event)
        }
        if (!this.options.quiet) {
            Position.prepare();
            Droppables.show(pointer, this.element)
        }
        Draggables.notify("onDrag", this, event);
        this.draw(pointer);
        if (this.options.change) {
            this.options.change(this)
        }
        if (this.options.scroll) {
            this.stopScrolling();
            var p;
            if (this.options.scroll == window) {
                with(this._getWindowScroll(this.options.scroll)) {
                    p = [left, top, left + width, top + height]
                }
            } else {
                p = Position.page(this.options.scroll);
                p[0] += this.options.scroll.scrollLeft + Position.deltaX;
                p[1] += this.options.scroll.scrollTop + Position.deltaY;
                p.push(p[0] + this.options.scroll.offsetWidth);
                p.push(p[1] + this.options.scroll.offsetHeight)
            }
            var speed = [0, 0];
            if (pointer[0] < (p[0] + this.options.scrollSensitivity)) {
                speed[0] = pointer[0] - (p[0] + this.options.scrollSensitivity)
            }
            if (pointer[1] < (p[1] + this.options.scrollSensitivity)) {
                speed[1] = pointer[1] - (p[1] + this.options.scrollSensitivity)
            }
            if (pointer[0] > (p[2] - this.options.scrollSensitivity)) {
                speed[0] = pointer[0] - (p[2] - this.options.scrollSensitivity)
            }
            if (pointer[1] > (p[3] - this.options.scrollSensitivity)) {
                speed[1] = pointer[1] - (p[3] - this.options.scrollSensitivity)
            }
            this.startScrolling(speed)
        }
        if (Prototype.Browser.WebKit) {
            window.scrollBy(0, 0)
        }
        Event.stop(event)
    },
    finishDrag: function(B, E) {
        this.dragging = false;
        if (this.options.quiet) {
            Position.prepare();
            var D = [Event.pointerX(B), Event.pointerY(B)];
            Droppables.show(D, this.element)
        }
        if (this.options.ghosting) {
            if (!this.element._originallyAbsolute) {
                Position.relativize(this.element)
            }
            delete this.element._originallyAbsolute;
            Element.remove(this._clone);
            this._clone = null
        }
        var F = false;
        if (E) {
            F = Droppables.fire(B, this.element);
            if (!F) {
                F = false
            }
        }
        if (F && this.options.onDropped) {
            this.options.onDropped(this.element)
        }
        Draggables.notify("onEnd", this, B);
        var A = this.options.revert;
        if (A && Object.isFunction(A)) {
            A = A(this.element)
        }
        var C = this.currentDelta();
        if (A && this.options.reverteffect) {
            if (F == 0 || A != "failure") {
                this.options.reverteffect(this.element, C[1] - this.delta[1], C[0] - this.delta[0])
            }
        } else {
            this.delta = C
        }
        if (this.options.zindex) {
            this.element.style.zIndex = this.originalZ
        }
        if (this.options.endeffect) {
            this.options.endeffect(this.element)
        }
        Draggables.deactivate(this);
        Droppables.reset()
    },
    keyPress: function(A) {
        if (A.keyCode != Event.KEY_ESC) {
            return
        }
        this.finishDrag(A, false);
        Event.stop(A)
    },
    endDrag: function(A) {
        if (!this.dragging) {
            return
        }
        this.stopScrolling();
        this.finishDrag(A, true);
        Event.stop(A)
    },
    draw: function(A) {
        var F = Position.cumulativeOffset(this.element);
        if (this.options.ghosting) {
            var C = Position.realOffset(this.element);
            F[0] += C[0] - Position.deltaX;
            F[1] += C[1] - Position.deltaY
        }
        var E = this.currentDelta();
        F[0] -= E[0];
        F[1] -= E[1];
        if (this.options.scroll && (this.options.scroll != window && this._isScrollChild)) {
            F[0] -= this.options.scroll.scrollLeft - this.originalScrollLeft;
            F[1] -= this.options.scroll.scrollTop - this.originalScrollTop
        }
        var D = [0, 1].map(function(G) {
            return (A[G] - F[G] - this.offset[G])
        }.bind(this));
        if (this.options.snap) {
            if (Object.isFunction(this.options.snap)) {
                D = this.options.snap(D[0], D[1], this)
            } else {
                if (Object.isArray(this.options.snap)) {
                    D = D.map(function(G, H) {
                        return (G / this.options.snap[H]).round() * this.options.snap[H]
                    }.bind(this))
                } else {
                    D = D.map(function(G) {
                        return (G / this.options.snap).round() * this.options.snap
                    }.bind(this))
                }
            }
        }
        var B = this.element.style;
        if ((!this.options.constraint) || (this.options.constraint == "horizontal")) {
            B.left = D[0] + "px"
        }
        if ((!this.options.constraint) || (this.options.constraint == "vertical")) {
            B.top = D[1] + "px"
        }
        if (B.visibility == "hidden") {
            B.visibility = ""
        }
    },
    stopScrolling: function() {
        if (this.scrollInterval) {
            clearInterval(this.scrollInterval);
            this.scrollInterval = null;
            Draggables._lastScrollPointer = null
        }
    },
    startScrolling: function(A) {
        if (!(A[0] || A[1])) {
            return
        }
        this.scrollSpeed = [A[0] * this.options.scrollSpeed, A[1] * this.options.scrollSpeed];
        this.lastScrolled = new Date();
        this.scrollInterval = setInterval(this.scroll.bind(this), 10)
    },
    scroll: function() {
        var current = new Date();
        var delta = current - this.lastScrolled;
        this.lastScrolled = current;
        if (this.options.scroll == window) {
            with(this._getWindowScroll(this.options.scroll)) {
                if (this.scrollSpeed[0] || this.scrollSpeed[1]) {
                    var d = delta / 1000;
                    this.options.scroll.scrollTo(left + d * this.scrollSpeed[0], top + d * this.scrollSpeed[1])
                }
            }
        } else {
            this.options.scroll.scrollLeft += this.scrollSpeed[0] * delta / 1000;
            this.options.scroll.scrollTop += this.scrollSpeed[1] * delta / 1000
        }
        Position.prepare();
        Droppables.show(Draggables._lastPointer, this.element);
        Draggables.notify("onDrag", this);
        if (this._isScrollChild) {
            Draggables._lastScrollPointer = Draggables._lastScrollPointer || $A(Draggables._lastPointer);
            Draggables._lastScrollPointer[0] += this.scrollSpeed[0] * delta / 1000;
            Draggables._lastScrollPointer[1] += this.scrollSpeed[1] * delta / 1000;
            if (Draggables._lastScrollPointer[0] < 0) {
                Draggables._lastScrollPointer[0] = 0
            }
            if (Draggables._lastScrollPointer[1] < 0) {
                Draggables._lastScrollPointer[1] = 0
            }
            this.draw(Draggables._lastScrollPointer)
        }
        if (this.options.change) {
            this.options.change(this)
        }
    },
    _getWindowScroll: function(w) {
        var T, L, W, H;
        with(w.document) {
            if (w.document.documentElement && documentElement.scrollTop) {
                T = documentElement.scrollTop;
                L = documentElement.scrollLeft
            } else {
                if (w.document.body) {
                    T = body.scrollTop;
                    L = body.scrollLeft
                }
            }
            if (w.innerWidth) {
                W = w.innerWidth;
                H = w.innerHeight
            } else {
                if (w.document.documentElement && documentElement.clientWidth) {
                    W = documentElement.clientWidth;
                    H = documentElement.clientHeight
                } else {
                    W = body.offsetWidth;
                    H = body.offsetHeight
                }
            }
        }
        return {
            top: T,
            left: L,
            width: W,
            height: H
        }
    }
});
Draggable._dragging = {};
var SortableObserver = Class.create({
    initialize: function(B, A) {
        this.element = $(B);
        this.observer = A;
        this.lastValue = Sortable.serialize(this.element)
    },
    onStart: function() {
        this.lastValue = Sortable.serialize(this.element)
    },
    onEnd: function() {
        Sortable.unmark();
        if (this.lastValue != Sortable.serialize(this.element)) {
            this.observer(this.element)
        }
    }
});
var Sortable = {
    SERIALIZE_RULE: /^[^_\-](?:[A-Za-z0-9\-\_]*)[_](.*)$/,
    sortables: {},
    _findRootElement: function(A) {
        while (A.tagName.toUpperCase() != "BODY") {
            if (A.id && Sortable.sortables[A.id]) {
                return A
            }
            A = A.parentNode
        }
    },
    options: function(A) {
        A = Sortable._findRootElement($(A));
        if (!A) {
            return
        }
        return Sortable.sortables[A.id]
    },
    destroy: function(A) {
        var B = Sortable.options(A);
        if (B) {
            Draggables.removeObserver(B.element);
            B.droppables.each(function(C) {
                Droppables.remove(C)
            });
            B.draggables.invoke("destroy");
            delete Sortable.sortables[B.element.id]
        }
    },
    create: function(C) {
        C = $(C);
        var B = Object.extend({
            element: C,
            tag: "li",
            dropOnEmpty: false,
            tree: false,
            treeTag: "ul",
            overlap: "vertical",
            constraint: "vertical",
            containment: C,
            handle: false,
            only: false,
            delay: 0,
            hoverclass: null,
            ghosting: false,
            quiet: false,
            scroll: false,
            scrollSensitivity: 20,
            scrollSpeed: 15,
            format: this.SERIALIZE_RULE,
            elements: false,
            handles: false,
            onChange: Prototype.emptyFunction,
            onUpdate: Prototype.emptyFunction
        }, arguments[1] || {});
        this.destroy(C);
        var A = {
            revert: true,
            quiet: B.quiet,
            scroll: B.scroll,
            scrollSpeed: B.scrollSpeed,
            scrollSensitivity: B.scrollSensitivity,
            delay: B.delay,
            ghosting: B.ghosting,
            constraint: B.constraint,
            handle: B.handle
        };
        if (B.starteffect) {
            A.starteffect = B.starteffect
        }
        if (B.reverteffect) {
            A.reverteffect = B.reverteffect
        } else {
            if (B.ghosting) {
                A.reverteffect = function(F) {
                    F.style.top = 0;
                    F.style.left = 0
                }
            }
        }
        if (B.endeffect) {
            A.endeffect = B.endeffect
        }
        if (B.zindex) {
            A.zindex = B.zindex
        }
        var D = {
            overlap: B.overlap,
            containment: B.containment,
            tree: B.tree,
            hoverclass: B.hoverclass,
            onHover: Sortable.onHover
        };
        var E = {
            onHover: Sortable.onEmptyHover,
            overlap: B.overlap,
            containment: B.containment,
            hoverclass: B.hoverclass
        };
        Element.cleanWhitespace(C);
        B.draggables = [];
        B.droppables = [];
        if (B.dropOnEmpty || B.tree) {
            Droppables.add(C, E);
            B.droppables.push(C)
        }(B.elements || this.findElements(C, B) || []).each(function(H, F) {
            var G = B.handles ? $(B.handles[F]) : (B.handle ? $(H).select("." + B.handle)[0] : H);
            B.draggables.push(new Draggable(H, Object.extend(A, {
                handle: G
            })));
            Droppables.add(H, D);
            if (B.tree) {
                H.treeNode = C
            }
            B.droppables.push(H)
        });
        if (B.tree) {
            (Sortable.findTreeElements(C, B) || []).each(function(F) {
                Droppables.add(F, E);
                F.treeNode = C;
                B.droppables.push(F)
            })
        }
        this.sortables[C.id] = B;
        Draggables.addObserver(new SortableObserver(C, B.onUpdate))
    },
    findElements: function(B, A) {
        return Element.findChildren(B, A.only, A.tree ? true : false, A.tag)
    },
    findTreeElements: function(B, A) {
        return Element.findChildren(B, A.only, A.tree ? true : false, A.treeTag)
    },
    onHover: function(E, D, A) {
        if (Element.isParent(D, E)) {
            return
        }
        if (A > 0.33 && A < 0.66 && Sortable.options(D).tree) {
            return
        } else {
            if (A > 0.5) {
                Sortable.mark(D, "before");
                if (D.previousSibling != E) {
                    var B = E.parentNode;
                    E.style.visibility = "hidden";
                    D.parentNode.insertBefore(E, D);
                    if (D.parentNode != B) {
                        Sortable.options(B).onChange(E)
                    }
                    Sortable.options(D.parentNode).onChange(E)
                }
            } else {
                Sortable.mark(D, "after");
                var C = D.nextSibling || null;
                if (C != E) {
                    var B = E.parentNode;
                    E.style.visibility = "hidden";
                    D.parentNode.insertBefore(E, C);
                    if (D.parentNode != B) {
                        Sortable.options(B).onChange(E)
                    }
                    Sortable.options(D.parentNode).onChange(E)
                }
            }
        }
    },
    onEmptyHover: function(E, G, H) {
        var I = E.parentNode;
        var A = Sortable.options(G);
        if (!Element.isParent(G, E)) {
            var F;
            var C = Sortable.findElements(G, {
                tag: A.tag,
                only: A.only
            });
            var B = null;
            if (C) {
                var D = Element.offsetSize(G, A.overlap) * (1 - H);
                for (F = 0; F < C.length; F += 1) {
                    if (D - Element.offsetSize(C[F], A.overlap) >= 0) {
                        D -= Element.offsetSize(C[F], A.overlap)
                    } else {
                        if (D - (Element.offsetSize(C[F], A.overlap) / 2) >= 0) {
                            B = F + 1 < C.length ? C[F + 1] : null;
                            break
                        } else {
                            B = C[F];
                            break
                        }
                    }
                }
            }
            G.insertBefore(E, B);
            Sortable.options(I).onChange(E);
            A.onChange(E)
        }
    },
    unmark: function() {
        if (Sortable._marker) {
            Sortable._marker.hide()
        }
    },
    mark: function(B, A) {
        var D = Sortable.options(B.parentNode);
        if (D && !D.ghosting) {
            return
        }
        if (!Sortable._marker) {
            Sortable._marker = ($("dropmarker") || Element.extend(document.createElement("DIV"))).hide().addClassName("dropmarker").setStyle({
                position: "absolute"
            });
            document.getElementsByTagName("body").item(0).appendChild(Sortable._marker)
        }
        var C = Position.cumulativeOffset(B);
        Sortable._marker.setStyle({
            left: C[0] + "px",
            top: C[1] + "px"
        });
        if (A == "after") {
            if (D.overlap == "horizontal") {
                Sortable._marker.setStyle({
                    left: (C[0] + B.clientWidth) + "px"
                })
            } else {
                Sortable._marker.setStyle({
                    top: (C[1] + B.clientHeight) + "px"
                })
            }
        }
        Sortable._marker.show()
    },
    _tree: function(E, B, F) {
        var D = Sortable.findElements(E, B) || [];
        for (var C = 0; C < D.length; ++C) {
            var A = D[C].id.match(B.format);
            if (!A) {
                continue
            }
            var G = {
                id: encodeURIComponent(A ? A[1] : null),
                element: E,
                parent: F,
                children: [],
                position: F.children.length,
                container: $(D[C]).down(B.treeTag)
            };
            if (G.container) {
                this._tree(G.container, B, G)
            }
            F.children.push(G)
        }
        return F
    },
    tree: function(D) {
        D = $(D);
        var C = this.options(D);
        var B = Object.extend({
            tag: C.tag,
            treeTag: C.treeTag,
            only: C.only,
            name: D.id,
            format: C.format
        }, arguments[1] || {});
        var A = {
            id: null,
            parent: null,
            children: [],
            container: D,
            position: 0
        };
        return Sortable._tree(D, B, A)
    },
    _constructIndex: function(B) {
        var A = "";
        do {
            if (B.id) {
                A = "[" + B.position + "]" + A
            }
        } while ((B = B.parent) != null);
        return A
    },
    sequence: function(B) {
        B = $(B);
        var A = Object.extend(this.options(B), arguments[1] || {});
        return $(this.findElements(B, A) || []).map(function(C) {
            return C.id.match(A.format) ? C.id.match(A.format)[1] : ""
        })
    },
    setSequence: function(B, C) {
        B = $(B);
        var A = Object.extend(this.options(B), arguments[2] || {});
        var D = {};
        this.findElements(B, A).each(function(E) {
            if (E.id.match(A.format)) {
                D[E.id.match(A.format)[1]] = [E, E.parentNode]
            }
            E.parentNode.removeChild(E)
        });
        C.each(function(E) {
            var F = D[E];
            if (F) {
                F[1].appendChild(F[0]);
                delete D[E]
            }
        })
    },
    serialize: function(C) {
        C = $(C);
        var B = Object.extend(Sortable.options(C), arguments[1] || {});
        var A = encodeURIComponent((arguments[1] && arguments[1].name) ? arguments[1].name : C.id);
        if (B.tree) {
            return Sortable.tree(C, arguments[1]).children.map(function(D) {
                return [A + Sortable._constructIndex(D) + "[id]=" + encodeURIComponent(D.id)].concat(D.children.map(arguments.callee))
            }).flatten().join("&")
        } else {
            return Sortable.sequence(C, arguments[1]).map(function(D) {
                return A + "[]=" + encodeURIComponent(D)
            }).join("&")
        }
    }
};
Element.isParent = function(B, A) {
    if (!B.parentNode || B == A) {
        return false
    }
    if (B.parentNode == A) {
        return true
    }
    return Element.isParent(B.parentNode, A)
};
Element.findChildren = function(D, B, A, C) {
    if (!D.hasChildNodes()) {
        return null
    }
    C = C.toUpperCase();
    if (B) {
        B = [B].flatten()
    }
    var E = [];
    $A(D.childNodes).each(function(G) {
        if (G.tagName && G.tagName.toUpperCase() == C && (!B || (Element.classNames(G).detect(function(H) {
            return B.include(H)
        })))) {
            E.push(G)
        }
        if (A) {
            var F = Element.findChildren(G, B, A, C);
            if (F) {
                E.push(F)
            }
        }
    });
    return (E.length > 0 ? E.flatten() : [])
};
Element.offsetSize = function(A, B) {
    return A["offset" + ((B == "vertical" || B == "height") ? "Height" : "Width")]
};
Array.prototype.indexOf = function(B) {
    for (var A = 0; A < this.length; A++) {
        if (this[A] == B) {
            return A
        }
    }
    return -1
};
Array.prototype.filter = function(C) {
    var B = [];
    for (var A = 0; A < this.length;
    A++) {
        if (C(this[A])) {
            B[B.length] = this[A]
        }
    }
    return B
};
String.prototype.right = function(A) {
    if (A >= this.length) {
        return this
    } else {
        return this.substr(this.length - A, A)
    }
};
var DateBocks = Class.create();
DateBocks.VERSION = "3.0.0";
DateBocks.prototype = {
    dateType: "numeric",
    dateBocksElement: null,
    autoRollOver: true,
    monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
    weekdayNames: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
    dateParsePatterns: [{
        re: /^tod|now/i,
        handler: function(A, B) {
            return new Date()
        }
    }, {
        re: /^tom/i,
        handler: function(A, B) {
            var C = new Date();
            C.setDate(C.getDate() + 1);
            return C
        }
    }, {
        re: /^yes/i,
        handler: function(A, B) {
            var C = new Date();
            C.setDate(C.getDate() - 1);
            return C
        }
    }, {
        re: /^(\d{1,2})(st|nd|rd|th)?$/i,
        handler: function(B, C) {
            var E = new Date();
            var F = E.getFullYear();
            var A = parseInt(C[1], 10);
            var D = E.getMonth();
            if (B.dateInRange(F, D, A)) {
                return B.getDateObj(F, D, A)
            }
        }
    }, {
        re: /^(\d{1,2})(?:st|nd|rd|th)? (?:of\s)?(\w+)$/i,
        handler: function(B, C) {
            var E = new Date();
            var F = E.getFullYear();
            var A = parseInt(C[1], 10);
            var D = B.parseMonth(C[2]);
            if (B.dateInRange(F, D, A)) {
                return B.getDateObj(F, D, A)
            }
        }
    }, {
        re: /^(\d{1,2})(?:st|nd|rd|th)? (?:of )?(\w+),? (\d{4})$/i,
        handler: function(A, B) {
            var C = new Date();
            C.setDate(parseInt(B[1], 10));
            C.setMonth(A.parseMonth(B[2]));
            C.setYear(B[3]);
            return C
        }
    }, {
        re: /^(\w+) (\d{1,2})(?:st|nd|rd|th)?$/i,
        handler: function(B, C) {
            var E = new Date();
            var F = E.getFullYear();
            var A = parseInt(C[2], 10);
            var D = B.parseMonth(C[1]);
            if (B.dateInRange(F, D, A)) {
                return B.getDateObj(F, D, A)
            }
        }
    }, {
        re: /^(\w+) (\d{1,2})(?:st|nd|rd|th)?,? (\d{4})$/i,
        handler: function(B, C) {
            var E = parseInt(C[3], 10);
            var A = parseInt(C[2], 10);
            var D = B.parseMonth(C[1]);
            if (B.dateInRange(E, D, A)) {
                return B.getDateObj(E, D, A)
            }
        }
    }, {
        re: /((next|last)\s(week|month|year))/i,
        handler: function(I, H) {
            var E = new Date();
            var F = E.getDate();
            var B = E.getMonth();
            var C = E.getFullYear();
            switch (H[3]) {
            case "week":
                var D = (H[2] == "next") ? (F + 7) : (F - 7);
                E.setDate(D);
                break;
            case "month":
                var G = (H[2] == "next") ? (B + 1) : (B - 1);
                E.setMonth(G);
                break;
            case "year":
                var A = (H[2] == "next") ? (C + 1) : (C - 1);
                E.setYear(A);
                break
            }
            return E
        }
    }, {
        re: /^(next|this)?\s?(\w+)$/i,
        handler: function(C, E) {
            var F = new Date();
            var B = F.getDay();
            var D = C.parseWeekday(E[2]);
            var A = D - B;
            if (D <= B) {
                A += 7
            }
            F.setDate(F.getDate() + A);
            return F
        }
    }, {
        re: /^last (\w+)$/i,
        handler: function(B, E) {
            var F = new Date();
            var D = F.getDay();
            var C = B.parseWeekday(E[1]);
            var A = (-1 * (D + 7 - C)) % 7;
            if (0 == A) {
                A = -7
            }
            F.setDate(F.getDate() + A);
            return F
        }
    }, {
        re: /(\d{1,2})\/(\d{1,2})\/(\d{4})/,
        handler: function(B, C) {
            if (B.dateType == "dd/mm/yyyy") {
                var E = parseInt(C[3], 10);
                var A = parseInt(C[1], 10);
                var D = parseInt(C[2], 10) - 1
            } else {
                var E = parseInt(C[3], 10);
                var A = parseInt(C[2], 10);
                var D = parseInt(C[1], 10) - 1
            }
            if (B.dateInRange(E, D, A)) {
                return B.getDateObj(E, D, A)
            }
        }
    }, {
        re: /(\d{1,2})\/(\d{1,2})\/(\d{1,2})/,
        handler: function(B, C) {
            var E = new Date();
            var F = E.getFullYear() - (E.getFullYear() % 100) + parseInt(C[3], 10);
            var A = parseInt(C[2], 10);
            var D = parseInt(C[1], 10) - 1;
            if (B.dateInRange(F, D, A)) {
                return B.getDateObj(F, D, A)
            }
        }
    }, {
        re: /(\d{1,2})\/(\d{1,2})/,
        handler: function(B, C) {
            var E = new Date();
            var F = E.getFullYear();
            var A = parseInt(C[2], 10);
            var D = parseInt(C[1], 10) - 1;
            if (B.dateInRange(F, D, A)) {
                return B.getDateObj(F, D, A)
            }
        }
    }, {
        re: /(\d{1,2})-(\d{1,2})-(\d{4})/,
        handler: function(B, C) {
            if (B.dateType == "dd-mm-yyyy") {
                var E = parseInt(C[3], 10);
                var A = parseInt(C[1], 10);
                var D = parseInt(C[2], 10) - 1
            } else {
                var E = parseInt(C[3], 10);
                var A = parseInt(C[2], 10);
                var D = parseInt(C[1], 10) - 1
            }
            if (B.dateInRange(E, D, A)) {
                return B.getDateObj(E, D, A)
            }
        }
    }, {
        re: /(\d{1,2})\.(\d{1,2})\.(\d{4})/,
        handler: function(B, C) {
            var A = parseInt(C[1], 10);
            var D = parseInt(C[2], 10) - 1;
            var E = parseInt(C[3], 10);
            if (B.dateInRange(E, D, A)) {
                return B.getDateObj(E, D, A)
            }
        }
    }, {
        re: /(\d{4})-(\d{1,2})-(\d{1,2})/,
        handler: function(B, C) {
            var E = parseInt(C[1], 10);
            var A = parseInt(C[3], 10);
            var D = parseInt(C[2], 10) - 1;
            if (B.dateInRange(E, D, A)) {
                return B.getDateObj(E, D, A)
            }
        }
    }, {
        re: /(\d{1,2})-(\d{1,2})-(\d{1,2})/,
        handler: function(B, C) {
            var E = new Date();
            var F = E.getFullYear() - (E.getFullYear() % 100) + parseInt(C[1], 10);
            var A = parseInt(C[3], 10);
            var D = parseInt(C[2], 10) - 1;
            if (B.dateInRange(F, D, A)) {
                return B.getDateObj(F, D, A)
            }
        }
    }, {
        re: /(\d{1,2})-(\d{1,2})/,
        handler: function(B, C) {
            var E = new Date();
            var F = E.getFullYear();
            var A = parseInt(C[2], 10);
            var D = parseInt(C[1], 10) - 1;
            if (B.dateInRange(F, D, A)) {
                return B.getDateObj(F, D, A)
            }
        }
    }, {
        re: /(\d{1,2})-(\w+)-(\d{4})/,
        handler: function(B, C) {
            var E = parseInt(C[3], 10);
            var A = parseInt(C[1], 10);
            var D = B.parseMonth(C[2]);
            if (B.dateInRange(E, D, A)) {
                return B.getDateObj(E, D, A)
            }
        }
    }, ],
    initialize: function(A) {
        Object.extend(this, A)
    },
    parseMonth: function(B) {
        var A = this.monthNames.filter(function(C) {
            return new RegExp("^" + B, "i").test(C)
        });
        if (A.length == 0) {
            throw new Error("Invalid month string")
        }
        if (A.length < 1) {
            throw new Error("Ambiguous month")
        }
        return this.monthNames.indexOf(A[0])
    },
    parseWeekday: function(B) {
        var A = this.weekdayNames.filter(function(C) {
            return new RegExp("^" + B, "i").test(C)
        });
        if (A.length == 0) {
            throw new Error("Invalid day string")
        }
        if (A.length < 1) {
            throw new Error("Ambiguous weekday")
        }
        return this.weekdayNames.indexOf(A[0])
    },
    dateInRange: function(D, C, A) {
        if (C < 0 || C > 11) {
            throw new Error("Invalid month value.  Valid months values are 1 to 12")
        }
        if (!this.autoRollOver) {
            var B = (11 == C) ? new Date(D + 1, 0, 0) : new Date(D, C + 1, 0);
            if (A < 1 || A > B.getDate()) {
                throw new Error("Invalid date value.  Valid date values for " + this.monthNames[C] + " are 1 to " + B.getDate().toString())
            }
        }
        return true
    },
    getDateObj: function(D, C, A) {
        var B = new Date();
        B.setDate(1);
        B.setYear(D);
        B.setMonth(C);
        B.setDate(A);
        return B
    },
    parseDateString: function(D) {
        var E = this.dateParsePatterns;
        for (var A = 0; A < E.length; A++) {
            var C = E[A].re;
            var B = E[A].handler;
            var F = C.exec(D);
            if (F) {
                return B(this, F)
            }
        }
        throw new Error("Invalid date string")
    },
    zeroPad: function(A) {
        if (A < 10) {
            return "0" + A
        } else {
            return A
        }
    },
    magicDate: function() {
        var B = this.dateBocksElement;
        try {
            var F = this.parseDateString(B.value);
            var A = this.zeroPad(F.getDate());
            var E = this.zeroPad(F.getMonth() + 1);
            var C = F.getFullYear();
            switch (this.dateType) {
            case "numeric":
                B.value = C + "" + E + "" + A;
                break;
            case "dd/mm/yyyy":
                B.value = A + "/" + E + "/" + C;
                break;
            case "dd-mm-yyyy":
                B.value = A + "-" + E + "-" + C;
                break;
            case "mm/dd/yyyy":
            case "us":
                B.value = E + "/" + A + "/" + C;
                break;
            case "mm.dd.yyyy":
            case "de":
                B.value = E + "." + A + "." + C;
                break;
            case "default":
            case "iso":
            case "yyyy-mm-dd":
            default:
                B.value = C + "-" + E + "-" + A;
                break
            }
            B.className = ""
        } catch (D) {}
    },
    trim: function(A) {
        return A.replace(/^\s+|\s+$/, "")
    },
    keyObserver: function(A, B) {
        var C = A.keyCode ? A.keyCode : ((A.which) ? A.which : A.charCode);
        if (C == 13 || C == 10) {
            switch (B) {
            case "parse":
                this.magicDate();
                break;
            case "return":
            case "false":
            default:
                return false;
                break
            }
        }
    }
};

function autoInit_trees() {
    var B = document.getElementsByTagName("ul");
    for (var A = 0;
    A < B.length; A++) {
        if (B[A].className && B[A].className.indexOf("tree") != -1) {
            initTree(B[A]);
            B[A].className = B[A].className.replace(/ ?unformatted ?/, " ")
        }
    }
}
function initTree(A) {
    var E, D;
    var H, G, F;
    var C, J, B;
    for (E = 0; E < A.childNodes.length; E++) {
        if (A.childNodes[E].tagName && A.childNodes[E].tagName.toLowerCase() == "li") {
            var I = A.childNodes[E];
            H = document.createElement("span");
            G = document.createElement("span");
            F = document.createElement("span");
            H.appendChild(G);
            G.appendChild(F);
            H.className = "a " + I.className.replace("closed", "spanClosed");
            H.onMouseOver = function() {};
            G.className = "b";
            G.onclick = update;
            F.className = "c";
            J = I.childNodes.length;
            C = 0;
            B = null;
            for (D = 0; D < I.childNodes.length; D++) {
                if (I.childNodes[D].tagName && I.childNodes[D].tagName.toLowerCase() == "div") {
                    C = D + 1;
                    continue
                }
                if (I.childNodes[D].tagName && I.childNodes[D].tagName.toLowerCase() == "ul") {
                    B = I.childNodes[D];
                    J = D;
                    break
                }
            }
            for (D = C; D < J; D++) {
                F.appendChild(I.childNodes[C])
            }
            if (I.childNodes.length > C) {
                I.insertBefore(H, I.childNodes[C])
            } else {
                I.appendChild(H)
            }
            if (B != null) {
                if (initTree(B)) {
                    addClass(I, "children", "closed");
                    addClass(H, "children", "spanClosed")
                }
            }
        }
    }
    if (I) {
        addClass(I, "last", "closed");
        addClass(H, "last", "spanClosed");
        return true
    } else {
        return false
    }
}
function treeToggle(C, D) {
    while (C != null && (!C.tagName || C.tagName.toLowerCase() != "li")) {
        C = C.parentNode
    }
    var A = findChildWithTag(C, "ul");
    var B = findChildWithTag(C, "span");
    if (D != null) {
        if (D == "open") {
            treeOpen(B, C)
        } else {
            if (D == "close") {
                treeClose(B, C)
            }
        }
    } else {
        if (A != null) {
            if (!C.className.match(/(^| )closed($| )/)) {
                treeClose(B, C)
            } else {
                treeOpen(B, C)
            }
        }
    }
}
function treeOpen(B, A) {
    removeClass(B, "spanClosed");
    removeClass(A, "closed")
}
function treeClose(B, A) {
    addClass(B, "spanClosed");
    addClass(A, "closed")
}
function findChildWithTag(C, A) {
    for (var B = 0;
    B < C.childNodes.length; B++) {
        if (C.childNodes[B].tagName != null && C.childNodes[B].tagName.toLowerCase() == A) {
            return C.childNodes[B]
        }
    }
    return null
}
function addClass(C, B, A) {
    if (A != null && C.className.match(new RegExp("(^| )" + A))) {
        C.className = C.className.replace(new RegExp("( |^)" + A), "$1" + B + " " + A)
    } else {
        if (!C.className.match(new RegExp("(^| )" + B + "($| )"))) {
            C.className += " " + B;
            C.className = C.className.replace(/(^ +)|( +$)/g, "")
        }
    }
}
function removeClass(C, B) {
    var A = C.className;
    var D = " " + C.className + " ";
    D = D.replace(new RegExp(" (" + B + " +)+", "g"), " ");
    C.className = D.replace(/(^ +)|( +$)/g, "")
}
_LOADERS = Array();

function callAllLoaders() {
    var B, A;
    for (B = 0; B < _LOADERS.length; B++) {
        A = _LOADERS[B];
        if (A != callAllLoaders) {
            A()
        }
    }
}
function appendLoader(A) {
    if (window.onload && window.onload != callAllLoaders) {
        _LOADERS[_LOADERS.length] = window.onload
    }
    window.onload = callAllLoaders;
    _LOADERS[_LOADERS.length] = A
}
appendLoader(autoInit_trees);
var Window = Class.create();
Window.keepMultiModalWindow = false;
Window.hasEffectLib = (typeof Effect != "undefined");
Window.resizeEffectDuration = 0.4;
Window.prototype = {
    initialize: function() {
        var C;
        var B = 0;
        if (arguments.length > 0) {
            if (typeof arguments[0] == "string") {
                C = arguments[0];
                B = 1
            } else {
                C = arguments[0] ? arguments[0].id : null
            }
        }
        if (!C) {
            C = "window_" + new Date().getTime()
        }
        if ($(C)) {
            alert("Window " + C + " is already registered in the DOM! Make sure you use setDestroyOnClose() or destroyOnClose: true in the constructor")
        }
        this.options = Object.extend({
            className: "dialog",
            blurClassName: null,
            minWidth: 100,
            minHeight: 20,
            resizable: true,
            closable: true,
            minimizable: true,
            maximizable: true,
            draggable: true,
            userData: null,
            showEffect: (Window.hasEffectLib ? Effect.Appear : Element.show),
            hideEffect: (Window.hasEffectLib ? Effect.Fade : Element.hide),
            showEffectOptions: {},
            hideEffectOptions: {},
            effectOptions: null,
            parent: document.body,
            title: "&nbsp;",
            url: null,
            onload: Prototype.emptyFunction,
            width: 200,
            height: 300,
            opacity: 1,
            recenterAuto: true,
            wiredDrag: false,
            closeCallback: null,
            destroyOnClose: false,
            gridX: 1,
            gridY: 1
        }, arguments[B] || {});
        if (this.options.blurClassName) {
            this.options.focusClassName = this.options.className
        }
        if (typeof this.options.top == "undefined" && typeof this.options.bottom == "undefined") {
            this.options.top = this._round(Math.random() * 500, this.options.gridY)
        }
        if (typeof this.options.left == "undefined" && typeof this.options.right == "undefined") {
            this.options.left = this._round(Math.random() * 500, this.options.gridX)
        }
        if (this.options.effectOptions) {
            Object.extend(this.options.hideEffectOptions, this.options.effectOptions);
            Object.extend(this.options.showEffectOptions, this.options.effectOptions);
            if (this.options.showEffect == Element.Appear) {
                this.options.showEffectOptions.to = this.options.opacity
            }
        }
        if (Window.hasEffectLib) {
            if (this.options.showEffect == Effect.Appear) {
                this.options.showEffectOptions.to = this.options.opacity
            }
            if (this.options.hideEffect == Effect.Fade) {
                this.options.hideEffectOptions.from = this.options.opacity
            }
        }
        if (this.options.hideEffect == Element.hide) {
            this.options.hideEffect = function() {
                Element.hide(this.element);
                if (this.options.destroyOnClose) {
                    this.destroy()
                }
            }.bind(this)
        }
        if (this.options.parent != document.body) {
            this.options.parent = $(this.options.parent)
        }
        this.element = this._createWindow(C);
        this.element.win = this;
        this.eventMouseDown = this._initDrag.bindAsEventListener(this);
        this.eventMouseUp = this._endDrag.bindAsEventListener(this);
        this.eventMouseMove = this._updateDrag.bindAsEventListener(this);
        this.eventOnLoad = this._getWindowBorderSize.bindAsEventListener(this);
        this.eventMouseDownContent = this.toFront.bindAsEventListener(this);
        this.eventResize = this._recenter.bindAsEventListener(this);
        this.topbar = $(this.element.id + "_top");
        this.bottombar = $(this.element.id + "_bottom");
        this.content = $(this.element.id + "_content");
        Event.observe(this.topbar, "mousedown", this.eventMouseDown);
        Event.observe(this.bottombar, "mousedown", this.eventMouseDown);
        Event.observe(this.content, "mousedown", this.eventMouseDownContent);
        Event.observe(window, "load", this.eventOnLoad);
        Event.observe(window, "resize", this.eventResize);
        Event.observe(window, "scroll", this.eventResize);
        Event.observe(this.options.parent, "scroll", this.eventResize);
        if (this.options.draggable) {
            var A = this;
            [this.topbar, this.topbar.up().previous(), this.topbar.up().next()].each(function(D) {
                D.observe("mousedown", A.eventMouseDown);
                D.addClassName("top_draggable")
            });
            [this.bottombar.up(), this.bottombar.up().previous(), this.bottombar.up().next()].each(function(D) {
                D.observe("mousedown", A.eventMouseDown);
                D.addClassName("bottom_draggable")
            })
        }
        if (this.options.resizable) {
            this.sizer = $(this.element.id + "_sizer");
            Event.observe(this.sizer, "mousedown", this.eventMouseDown)
        }
        this.useLeft = null;
        this.useTop = null;
        if (typeof this.options.left != "undefined") {
            this.element.setStyle({
                left: parseFloat(this.options.left) + "px"
            });
            this.useLeft = true
        } else {
            this.element.setStyle({
                right: parseFloat(this.options.right) + "px"
            });
            this.useLeft = false
        }
        if (typeof this.options.top != "undefined") {
            this.element.setStyle({
                top: parseFloat(this.options.top) + "px"
            });
            this.useTop = true
        } else {
            this.element.setStyle({
                bottom: parseFloat(this.options.bottom) + "px"
            });
            this.useTop = false
        }
        this.storedLocation = null;
        this.setOpacity(this.options.opacity);
        if (this.options.zIndex) {
            this.setZIndex(this.options.zIndex)
        }
        if (this.options.destroyOnClose) {
            this.setDestroyOnClose(true)
        }
        this._getWindowBorderSize();
        this.width = this.options.width;
        this.height = this.options.height;
        this.visible = false;
        this.constraint = false;
        this.constraintPad = {
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        };
        if (this.width && this.height) {
            this.setSize(this.options.width, this.options.height)
        }
        this.setTitle(this.options.title);
        Windows.register(this)
    },
    destroy: function() {
        this._notify("onDestroy");
        Event.stopObserving(this.topbar, "mousedown", this.eventMouseDown);
        Event.stopObserving(this.bottombar, "mousedown", this.eventMouseDown);
        Event.stopObserving(this.content, "mousedown", this.eventMouseDownContent);
        Event.stopObserving(window, "load", this.eventOnLoad);
        Event.stopObserving(window, "resize", this.eventResize);
        Event.stopObserving(window, "scroll", this.eventResize);
        Event.stopObserving(this.content, "load", this.options.onload);
        if (this._oldParent) {
            var C = this.getContent();
            var A = null;
            for (var B = 0; B < C.childNodes.length;
            B++) {
                A = C.childNodes[B];
                if (A.nodeType == 1) {
                    break
                }
                A = null
            }
            if (A) {
                this._oldParent.appendChild(A)
            }
            this._oldParent = null
        }
        if (this.sizer) {
            Event.stopObserving(this.sizer, "mousedown", this.eventMouseDown)
        }
        if (this.options.url) {
            this.content.src = null
        }
        if (this.iefix) {
            Element.remove(this.iefix)
        }
        Element.remove(this.element);
        Windows.unregister(this)
    },
    setCloseCallback: function(A) {
        this.options.closeCallback = A
    },
    getContent: function() {
        return this.content
    },
    setContent: function(G, F, B) {
        var A = $(G);
        if (null == A) {
            throw "Unable to find element '" + G + "' in DOM"
        }
        this._oldParent = A.parentNode;
        var E = null;
        var D = null;
        if (F) {
            E = Element.getDimensions(A)
        }
        if (B) {
            D = Position.cumulativeOffset(A)
        }
        var C = this.getContent();
        this.setHTMLContent("");
        C = this.getContent();
        C.appendChild(A);
        A.show();
        if (F) {
            this.setSize(E.width, E.height)
        }
        if (B) {
            this.setLocation(D[1] - this.heightN, D[0] - this.widthW)
        }
    },
    setHTMLContent: function(A) {
        if (this.options.url) {
            this.content.src = null;
            this.options.url = null;
            var B = '<div id="' + this.getId() + '_content" class="' + this.options.className + '_content"> </div>';
            $(this.getId() + "_table_content").innerHTML = B;
            this.content = $(this.element.id + "_content")
        }
        this.getContent().innerHTML = A
    },
    setAjaxContent: function(B, A, D, C) {
        this.showFunction = D ? "showCenter" : "show";
        this.showModal = C || false;
        A = A || {};
        this.setHTMLContent("");
        this.onComplete = A.onComplete;
        if (!this._onCompleteHandler) {
            this._onCompleteHandler = this._setAjaxContent.bind(this)
        }
        A.onComplete = this._onCompleteHandler;
        new Ajax.Request(B, A);
        A.onComplete = this.onComplete
    },
    _setAjaxContent: function(A) {
        Element.update(this.getContent(), A.responseText);
        if (this.onComplete) {
            this.onComplete(A)
        }
        this.onComplete = null;
        this[this.showFunction](this.showModal)
    },
    setURL: function(A) {
        if (this.options.url) {
            this.content.src = null
        }
        this.options.url = A;
        var B = "<iframe frameborder='0' name='" + this.getId() + "_content'  id='" + this.getId() + "_content' src='" + A + "' width='" + this.width + "' height='" + this.height + "'> </iframe>";
        $(this.getId() + "_table_content").innerHTML = B;
        this.content = $(this.element.id + "_content")
    },
    getURL: function() {
        return this.options.url ? this.options.url : null
    },
    refresh: function() {
        if (this.options.url) {
            $(this.element.getAttribute("id") + "_content").src = this.options.url
        }
    },
    setCookie: function(B, C, M, E, A) {
        B = B || this.element.id;
        this.cookie = [B, C, M, E, A];
        var K = WindowUtilities.getCookie(B);
        if (K) {
            var L = K.split(",");
            var I = L[0].split(":");
            var H = L[1].split(":");
            var J = parseFloat(L[2]),
                F = parseFloat(L[3]);
            var G = L[4];
            var D = L[5];
            this.setSize(J, F);
            if (G == "true") {
                this.doMinimize = true
            } else {
                if (D == "true") {
                    this.doMaximize = true
                }
            }
            this.useLeft = I[0] == "l";
            this.useTop = H[0] == "t";
            this.element.setStyle(this.useLeft ? {
                left: I[1]
            } : {
                right: I[1]
            });
            this.element.setStyle(this.useTop ? {
                top: H[1]
            } : {
                bottom: H[1]
            })
        }
    },
    getId: function() {
        return this.element.id
    },
    setDestroyOnClose: function() {
        this.options.destroyOnClose = true
    },
    setConstraint: function(A, B) {
        this.constraint = A;
        this.constraintPad = Object.extend(this.constraintPad, B || {});
        if (this.useTop && this.useLeft) {
            this.setLocation(parseFloat(this.element.style.top), parseFloat(this.element.style.left))
        }
    },
    _initDrag: function(B) {
        if (Event.element(B) == this.sizer && this.isMinimized()) {
            return
        }
        if (Event.element(B) != this.sizer && this.isMaximized()) {
            return
        }
        if (Prototype.Browser.IE && this.heightN == 0) {
            this._getWindowBorderSize()
        }
        this.pointer = [this._round(Event.pointerX(B), this.options.gridX), this._round(Event.pointerY(B), this.options.gridY)];
        if (this.options.wiredDrag) {
            this.currentDrag = this._createWiredElement()
        } else {
            this.currentDrag = this.element
        }
        if (Event.element(B) == this.sizer) {
            this.doResize = true;
            this.widthOrg = this.width;
            this.heightOrg = this.height;
            this.bottomOrg = parseFloat(this.element.getStyle("bottom"));
            this.rightOrg = parseFloat(this.element.getStyle("right"));
            this._notify("onStartResize")
        } else {
            this.doResize = false;
            var A = $(this.getId() + "_close");
            if (A && Position.within(A, this.pointer[0], this.pointer[1])) {
                this.currentDrag = null;
                return
            }
            this.toFront();
            if (!this.options.draggable) {
                return
            }
            this._notify("onStartMove")
        }
        Event.observe(document, "mouseup", this.eventMouseUp, false);
        Event.observe(document, "mousemove", this.eventMouseMove, false);
        WindowUtilities.disableScreen("__invisible__", "__invisible__", this.overlayOpacity);
        document.body.ondrag = function() {
            return false
        };
        document.body.onselectstart = function() {
            return false
        };
        this.currentDrag.show();
        Event.stop(B)
    },
    _round: function(B, A) {
        return A == 1 ? B : B = Math.floor(B / A) * A
    },
    _updateDrag: function(B) {
        var A = [this._round(Event.pointerX(B), this.options.gridX), this._round(Event.pointerY(B), this.options.gridY)];
        var J = A[0] - this.pointer[0];
        var I = A[1] - this.pointer[1];
        if (this.doResize) {
            var H = this.widthOrg + J;
            var D = this.heightOrg + I;
            J = this.width - this.widthOrg;
            I = this.height - this.heightOrg;
            if (this.useLeft) {
                H = this._updateWidthConstraint(H)
            } else {
                this.currentDrag.setStyle({
                    right: (this.rightOrg - J) + "px"
                })
            }
            if (this.useTop) {
                D = this._updateHeightConstraint(D)
            } else {
                this.currentDrag.setStyle({
                    bottom: (this.bottomOrg - I) + "px"
                })
            }
            this.setSize(H, D);
            this._notify("onResize")
        } else {
            this.pointer = A;
            if (this.useLeft) {
                var C = parseFloat(this.currentDrag.getStyle("left")) + J;
                var G = this._updateLeftConstraint(C);
                this.pointer[0] += G - C;
                this.currentDrag.setStyle({
                    left: G + "px"
                })
            } else {
                this.currentDrag.setStyle({
                    right: parseFloat(this.currentDrag.getStyle("right")) - J + "px"
                })
            }
            if (this.useTop) {
                var F = parseFloat(this.currentDrag.getStyle("top")) + I;
                var E = this._updateTopConstraint(F);
                this.pointer[1] += E - F;
                this.currentDrag.setStyle({
                    top: E + "px"
                })
            } else {
                this.currentDrag.setStyle({
                    bottom: parseFloat(this.currentDrag.getStyle("bottom")) - I + "px"
                })
            }
            this._notify("onMove")
        }
        if (this.iefix) {
            this._fixIEOverlapping()
        }
        this._removeStoreLocation();
        Event.stop(B)
    },
    _endDrag: function(A) {
        WindowUtilities.enableScreen("__invisible__");
        if (this.doResize) {
            this._notify("onEndResize")
        } else {
            this._notify("onEndMove")
        }
        Event.stopObserving(document, "mouseup", this.eventMouseUp, false);
        Event.stopObserving(document, "mousemove", this.eventMouseMove, false);
        Event.stop(A);
        this._hideWiredElement();
        this._saveCookie();
        document.body.ondrag = null;
        document.body.onselectstart = null
    },
    _updateLeftConstraint: function(B) {
        if (this.constraint && this.useLeft && this.useTop) {
            var A = this.options.parent == document.body ? WindowUtilities.getPageSize().windowWidth : this.options.parent.getDimensions().width;
            if (B < this.constraintPad.left) {
                B = this.constraintPad.left
            }
            if (B + this.width + this.widthE + this.widthW > A - this.constraintPad.right) {
                B = A - this.constraintPad.right - this.width - this.widthE - this.widthW
            }
        }
        return B
    },
    _updateTopConstraint: function(C) {
        if (this.constraint && this.useLeft && this.useTop) {
            var A = this.options.parent == document.body ? WindowUtilities.getPageSize().windowHeight : this.options.parent.getDimensions().height;
            var B = this.height + this.heightN + this.heightS;
            if (C < this.constraintPad.top) {
                C = this.constraintPad.top
            }
            if (C + B > A - this.constraintPad.bottom) {
                C = A - this.constraintPad.bottom - B
            }
        }
        return C
    },
    _updateWidthConstraint: function(A) {
        if (this.constraint && this.useLeft && this.useTop) {
            var B = this.options.parent == document.body ? WindowUtilities.getPageSize().windowWidth : this.options.parent.getDimensions().width;
            var C = parseFloat(this.element.getStyle("left"));
            if (C + A + this.widthE + this.widthW > B - this.constraintPad.right) {
                A = B - this.constraintPad.right - C - this.widthE - this.widthW
            }
        }
        return A
    },
    _updateHeightConstraint: function(B) {
        if (this.constraint && this.useLeft && this.useTop) {
            var A = this.options.parent == document.body ? WindowUtilities.getPageSize().windowHeight : this.options.parent.getDimensions().height;
            var C = parseFloat(this.element.getStyle("top"));
            if (C + B + this.heightN + this.heightS > A - this.constraintPad.bottom) {
                B = A - this.constraintPad.bottom - C - this.heightN - this.heightS
            }
        }
        return B
    },
    _createWindow: function(A) {
        var F = this.options.className;
        var D = document.createElement("div");
        D.setAttribute("id", A);
        D.className = "dialog";
        var E;
        if (this.options.url) {
            E = '<iframe frameborder="0" name="' + A + '_content"  id="' + A + '_content" src="' + this.options.url + '"> </iframe>'
        } else {
            E = '<div id="' + A + '_content" class="' + F + '_content"> </div>'
        }
        var G = this.options.closable ? "<div class='" + F + "_close' id='" + A + "_close' onclick='Windows.close(\"" + A + "\", event)'> </div>" : "";
        var H = this.options.minimizable ? "<div class='" + F + "_minimize' id='" + A + "_minimize' onclick='Windows.minimize(\"" + A + "\", event)'> </div>" : "";
        var I = this.options.maximizable ? "<div class='" + F + "_maximize' id='" + A + "_maximize' onclick='Windows.maximize(\"" + A + "\", event)'> </div>" : "";
        var C = this.options.resizable ? "class='" + F + "_sizer' id='" + A + "_sizer'" : "class='" + F + "_se'";
        var B = "../themes/default/blank.gif";
        D.innerHTML = G + H + I + "      <table id='" + A + "_row1' class=\"top table_window\">        <tr>          <td class='" + F + "_nw'></td>          <td class='" + F + "_n'><div id='" + A + "_top' class='" + F + "_title title_window'>" + this.options.title + "</div></td>          <td class='" + F + "_ne'></td>        </tr>      </table>      <table id='" + A + "_row2' class=\"mid table_window\">        <tr>          <td class='" + F + "_w'></td>            <td id='" + A + "_table_content' class='" + F + "_content' valign='top'>" + E + "</td>          <td class='" + F + "_e'></td>        </tr>      </table>        <table id='" + A + "_row3' class=\"bot table_window\">        <tr>          <td class='" + F + "_sw'></td>            <td class='" + F + "_s'><div id='" + A + "_bottom' class='status_bar'><span style='float:left; width:1px; height:1px'></span></div></td>            <td " + C + "></td>        </tr>      </table>    ";
        Element.hide(D);
        this.options.parent.insertBefore(D, this.options.parent.firstChild);
        Event.observe($(A + "_content"), "load", this.options.onload);
        return D
    },
    changeClassName: function(A) {
        var B = this.options.className;
        var C = this.getId();
        $A(["_close", "_minimize", "_maximize", "_sizer", "_content"]).each(function(D) {
            this._toggleClassName($(C + D), B + D, A + D)
        }.bind(this));
        this._toggleClassName($(C + "_top"), B + "_title", A + "_title");
        $$("#" + C + " td").each(function(D) {
            D.className = D.className.sub(B, A)
        });
        this.options.className = A
    },
    _toggleClassName: function(C, B, A) {
        if (C) {
            C.removeClassName(B);
            C.addClassName(A)
        }
    },
    setLocation: function(C, B) {
        C = this._updateTopConstraint(C);
        B = this._updateLeftConstraint(B);
        var A = this.currentDrag || this.element;
        A.setStyle({
            top: C + "px"
        });
        A.setStyle({
            left: B + "px"
        });
        this.useLeft = true;
        this.useTop = true
    },
    getLocation: function() {
        var A = {};
        if (this.useTop) {
            A = Object.extend(A, {
                top: this.element.getStyle("top")
            })
        } else {
            A = Object.extend(A, {
                bottom: this.element.getStyle("bottom")
            })
        }
        if (this.useLeft) {
            A = Object.extend(A, {
                left: this.element.getStyle("left")
            })
        } else {
            A = Object.extend(A, {
                right: this.element.getStyle("right")
            })
        }
        return A
    },
    getSize: function() {
        return {
            width: this.width,
            height: this.height
        }
    },
    setSize: function(C, B, A) {
        C = parseFloat(C);
        B = parseFloat(B);
        if (!this.minimized && C < this.options.minWidth) {
            C = this.options.minWidth
        }
        if (!this.minimized && B < this.options.minHeight) {
            B = this.options.minHeight
        }
        if (this.options.maxHeight && B > this.options.maxHeight) {
            B = this.options.maxHeight
        }
        if (this.options.maxWidth && C > this.options.maxWidth) {
            C = this.options.maxWidth
        }
        if (this.useTop && this.useLeft && Window.hasEffectLib && Effect.ResizeWindow && A) {
            new Effect.ResizeWindow(this, null, null, C, B, {
                duration: Window.resizeEffectDuration
            })
        } else {
            this.width = C;
            this.height = B;
            var E = this.currentDrag ? this.currentDrag : this.element;
            E.setStyle({
                width: C + this.widthW + this.widthE + "px"
            });
            E.setStyle({
                height: B + this.heightN + this.heightS + "px"
            });
            if (!this.currentDrag || this.currentDrag == this.element) {
                var D = $(this.element.id + "_content");
                D.setStyle({
                    height: B + "px"
                });
                D.setStyle({
                    width: C + "px"
                })
            }
        }
    },
    updateHeight: function() {
        this.setSize(this.width, this.content.scrollHeight, true)
    },
    updateWidth: function() {
        this.setSize(this.content.scrollWidth, this.height, true)
    },
    toFront: function() {
        if (this.element.style.zIndex < Windows.maxZIndex) {
            this.setZIndex(Windows.maxZIndex + 1)
        }
        if (this.iefix) {
            this._fixIEOverlapping()
        }
    },
    getBounds: function(B) {
        if (!this.width || !this.height || !this.visible) {
            this.computeBounds()
        }
        var A = this.width;
        var C = this.height;
        if (!B) {
            A += this.widthW + this.widthE;
            C += this.heightN + this.heightS
        }
        var D = Object.extend(this.getLocation(), {
            width: A + "px",
            height: C + "px"
        });
        return D
    },
    computeBounds: function() {
        if (!this.width || !this.height) {
            var A = WindowUtilities._computeSize(this.content.innerHTML, this.content.id, this.width, this.height, 0, this.options.className);
            if (this.height) {
                this.width = A + 5
            } else {
                this.height = A + 5
            }
        }
        this.setSize(this.width, this.height);
        if (this.centered) {
            this._center(this.centerTop, this.centerLeft)
        }
    },
    show: function(B) {
        this.visible = true;
        if (B) {
            if (typeof this.overlayOpacity == "undefined") {
                var A = this;
                setTimeout(function() {
                    A.show(B)
                }, 10);
                return
            }
            Windows.addModalWindow(this);
            this.modal = true;
            this.setZIndex(Windows.maxZIndex + 1);
            Windows.unsetOverflow(this)
        } else {
            if (!this.element.style.zIndex) {
                this.setZIndex(Windows.maxZIndex + 1)
            }
        }
        if (this.oldStyle) {
            this.getContent().setStyle({
                overflow: this.oldStyle
            })
        }
        this.computeBounds();
        this._notify("onBeforeShow");
        if (this.options.showEffect != Element.show && this.options.showEffectOptions) {
            this.options.showEffect(this.element, this.options.showEffectOptions)
        } else {
            this.options.showEffect(this.element)
        }
        this._checkIEOverlapping();
        WindowUtilities.focusedWindow = this;
        this._notify("onShow")
    },
    showCenter: function(A, C, B) {
        this.centered = true;
        this.centerTop = C;
        this.centerLeft = B;
        this.show(A)
    },
    isVisible: function() {
        return this.visible
    },
    _center: function(C, B) {
        var D = WindowUtilities.getWindowScroll(this.options.parent);
        var A = WindowUtilities.getPageSize(this.options.parent);
        if (typeof C == "undefined") {
            C = (A.windowHeight - (this.height + this.heightN + this.heightS)) / 2
        }
        C += D.top;
        if (typeof B == "undefined") {
            B = (A.windowWidth - (this.width + this.widthW + this.widthE)) / 2
        }
        B += D.left;
        this.setLocation(C, B);
        this.toFront()
    },
    _recenter: function(B) {
        if (this.centered) {
            var A = WindowUtilities.getPageSize(this.options.parent);
            var C = WindowUtilities.getWindowScroll(this.options.parent);
            if (this.pageSize && this.pageSize.windowWidth == A.windowWidth && this.pageSize.windowHeight == A.windowHeight && this.windowScroll.left == C.left && this.windowScroll.top == C.top) {
                return
            }
            this.pageSize = A;
            this.windowScroll = C;
            if ($("overlay_modal")) {
                $("overlay_modal").setStyle({
                    height: (A.pageHeight + "px")
                })
            }
            if (this.options.recenterAuto) {
                this._center(this.centerTop, this.centerLeft)
            }
        }
    },
    hide: function() {
        this.visible = false;
        if (this.modal) {
            Windows.removeModalWindow(this);
            Windows.resetOverflow()
        }
        this.oldStyle = this.getContent().getStyle("overflow") || "auto";
        this.getContent().setStyle({
            overflow: "hidden"
        });
        this.options.hideEffect(this.element, this.options.hideEffectOptions);
        if (this.iefix) {
            this.iefix.hide()
        }
        if (!this.doNotNotifyHide) {
            this._notify("onHide")
        }
    },
    close: function() {
        if (this.visible) {
            if (this.options.closeCallback && !this.options.closeCallback(this)) {
                return
            }
            if (this.options.destroyOnClose) {
                var A = this.destroy.bind(this);
                if (this.options.hideEffectOptions.afterFinish) {
                    var B = this.options.hideEffectOptions.afterFinish;
                    this.options.hideEffectOptions.afterFinish = function() {
                        B();
                        A()
                    }
                } else {
                    this.options.hideEffectOptions.afterFinish = function() {
                        A()
                    }
                }
            }
            Windows.updateFocusedWindow();
            this.doNotNotifyHide = true;
            this.hide();
            this.doNotNotifyHide = false;
            this._notify("onClose")
        }
    },
    minimize: function() {
        if (this.resizing) {
            return
        }
        var A = $(this.getId() + "_row2");
        if (!this.minimized) {
            this.minimized = true;
            var D = A.getDimensions().height;
            this.r2Height = D;
            var C = this.element.getHeight() - D;
            if (this.useLeft && this.useTop && Window.hasEffectLib && Effect.ResizeWindow) {
                new Effect.ResizeWindow(this, null, null, null, this.height - D, {
                    duration: Window.resizeEffectDuration
                })
            } else {
                this.height -= D;
                this.element.setStyle({
                    height: C + "px"
                });
                A.hide()
            }
            if (!this.useTop) {
                var B = parseFloat(this.element.getStyle("bottom"));
                this.element.setStyle({
                    bottom: (B + D) + "px"
                })
            }
        } else {
            this.minimized = false;
            var D = this.r2Height;
            this.r2Height = null;
            if (this.useLeft && this.useTop && Window.hasEffectLib && Effect.ResizeWindow) {
                new Effect.ResizeWindow(this, null, null, null, this.height + D, {
                    duration: Window.resizeEffectDuration
                })
            } else {
                var C = this.element.getHeight() + D;
                this.height += D;
                this.element.setStyle({
                    height: C + "px"
                });
                A.show()
            }
            if (!this.useTop) {
                var B = parseFloat(this.element.getStyle("bottom"));
                this.element.setStyle({
                    bottom: (B - D) + "px"
                })
            }
            this.toFront()
        }
        this._notify("onMinimize");
        this._saveCookie()
    },
    maximize: function() {
        if (this.isMinimized() || this.resizing) {
            return
        }
        if (Prototype.Browser.IE && this.heightN == 0) {
            this._getWindowBorderSize()
        }
        if (this.storedLocation != null) {
            this._restoreLocation();
            if (this.iefix) {
                this.iefix.hide()
            }
        } else {
            this._storeLocation();
            Windows.unsetOverflow(this);
            var G = WindowUtilities.getWindowScroll(this.options.parent);
            var B = WindowUtilities.getPageSize(this.options.parent);
            var F = G.left;
            var E = G.top;
            if (this.options.parent != document.body) {
                G = {
                    top: 0,
                    left: 0,
                    bottom: 0,
                    right: 0
                };
                var D = this.options.parent.getDimensions();
                B.windowWidth = D.width;
                B.windowHeight = D.height;
                E = 0;
                F = 0
            }
            if (this.constraint) {
                B.windowWidth -= Math.max(0, this.constraintPad.left) + Math.max(0, this.constraintPad.right);
                B.windowHeight -= Math.max(0, this.constraintPad.top) + Math.max(0, this.constraintPad.bottom);
                F += Math.max(0, this.constraintPad.left);
                E += Math.max(0, this.constraintPad.top)
            }
            var C = B.windowWidth - this.widthW - this.widthE;
            var A = B.windowHeight - this.heightN - this.heightS;
            if (this.useLeft && this.useTop && Window.hasEffectLib && Effect.ResizeWindow) {
                new Effect.ResizeWindow(this, E, F, C, A, {
                    duration: Window.resizeEffectDuration
                })
            } else {
                this.setSize(C, A);
                this.element.setStyle(this.useLeft ? {
                    left: F
                } : {
                    right: F
                });
                this.element.setStyle(this.useTop ? {
                    top: E
                } : {
                    bottom: E
                })
            }
            this.toFront();
            if (this.iefix) {
                this._fixIEOverlapping()
            }
        }
        this._notify("onMaximize");
        this._saveCookie()
    },
    isMinimized: function() {
        return this.minimized
    },
    isMaximized: function() {
        return (this.storedLocation != null)
    },
    setOpacity: function(A) {
        if (Element.setOpacity) {
            Element.setOpacity(this.element, A)
        }
    },
    setZIndex: function(A) {
        this.element.setStyle({
            zIndex: A
        });
        Windows.updateZindex(A, this)
    },
    setTitle: function(A) {
        if (!A || A == "") {
            A = "&nbsp;"
        }
        Element.update(this.element.id + "_top", A)
    },
    getTitle: function() {
        return $(this.element.id + "_top").innerHTML
    },
    setStatusBar: function(B) {
        var A = $(this.getId() + "_bottom");
        if (typeof(B) == "object") {
            if (this.bottombar.firstChild) {
                this.bottombar.replaceChild(B, this.bottombar.firstChild)
            } else {
                this.bottombar.appendChild(B)
            }
        } else {
            this.bottombar.innerHTML = B
        }
    },
    _checkIEOverlapping: function() {
        if (!this.iefix && (navigator.appVersion.indexOf("MSIE") > 0) && (navigator.userAgent.indexOf("Opera") < 0) && (this.element.getStyle("position") == "absolute")) {
            new Insertion.After(this.element.id, '<iframe id="' + this.element.id + '_iefix" style="display:none;position:absolute;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);" src="javascript:false;" frameborder="0" scrolling="no"></iframe>');
            this.iefix = $(this.element.id + "_iefix")
        }
        if (this.iefix) {
            setTimeout(this._fixIEOverlapping.bind(this), 50)
        }
    },
    _fixIEOverlapping: function() {
        Position.clone(this.element, this.iefix);
        this.iefix.style.zIndex = this.element.style.zIndex - 1;
        this.iefix.show()
    },
    _getWindowBorderSize: function(B) {
        var C = this._createHiddenDiv(this.options.className + "_n");
        this.heightN = Element.getDimensions(C).height;
        C.parentNode.removeChild(C);
        var C = this._createHiddenDiv(this.options.className + "_s");
        this.heightS = Element.getDimensions(C).height;
        C.parentNode.removeChild(C);
        var C = this._createHiddenDiv(this.options.className + "_e");
        this.widthE = Element.getDimensions(C).width;
        C.parentNode.removeChild(C);
        var C = this._createHiddenDiv(this.options.className + "_w");
        this.widthW = Element.getDimensions(C).width;
        C.parentNode.removeChild(C);
        var C = document.createElement("div");
        C.className = "overlay_" + this.options.className;
        document.body.appendChild(C);
        var A = this;
        setTimeout(function() {
            A.overlayOpacity = ($(C).getStyle("opacity"));
            C.parentNode.removeChild(C)
        }, 10);
        if (Prototype.Browser.IE) {
            this.heightS = $(this.getId() + "_row3").getDimensions().height;
            this.heightN = $(this.getId() + "_row1").getDimensions().height
        }
        if (Prototype.Browser.WebKit && Prototype.Browser.WebKitVersion < 420) {
            this.setSize(this.width, this.height)
        }
        if (this.doMaximize) {
            this.maximize()
        }
        if (this.doMinimize) {
            this.minimize()
        }
    },
    _createHiddenDiv: function(B) {
        var A = document.body;
        var C = document.createElement("div");
        C.setAttribute("id", this.element.id + "_tmp");
        C.className = B;
        C.style.display = "none";
        C.innerHTML = "";
        A.insertBefore(C, A.firstChild);
        return C
    },
    _storeLocation: function() {
        if (this.storedLocation == null) {
            this.storedLocation = {
                useTop: this.useTop,
                useLeft: this.useLeft,
                top: this.element.getStyle("top"),
                bottom: this.element.getStyle("bottom"),
                left: this.element.getStyle("left"),
                right: this.element.getStyle("right"),
                width: this.width,
                height: this.height
            }
        }
    },
    _restoreLocation: function() {
        if (this.storedLocation != null) {
            this.useLeft = this.storedLocation.useLeft;
            this.useTop = this.storedLocation.useTop;
            if (this.useLeft && this.useTop && Window.hasEffectLib && Effect.ResizeWindow) {
                new Effect.ResizeWindow(this, this.storedLocation.top, this.storedLocation.left, this.storedLocation.width, this.storedLocation.height, {
                    duration: Window.resizeEffectDuration
                })
            } else {
                this.element.setStyle(this.useLeft ? {
                    left: this.storedLocation.left
                } : {
                    right: this.storedLocation.right
                });
                this.element.setStyle(this.useTop ? {
                    top: this.storedLocation.top
                } : {
                    bottom: this.storedLocation.bottom
                });
                this.setSize(this.storedLocation.width, this.storedLocation.height)
            }
            Windows.resetOverflow();
            this._removeStoreLocation()
        }
    },
    _removeStoreLocation: function() {
        this.storedLocation = null
    },
    _saveCookie: function() {
        if (this.cookie) {
            var A = "";
            if (this.useLeft) {
                A += "l:" + (this.storedLocation ? this.storedLocation.left : this.element.getStyle("left"))
            } else {
                A += "r:" + (this.storedLocation ? this.storedLocation.right : this.element.getStyle("right"))
            }
            if (this.useTop) {
                A += ",t:" + (this.storedLocation ? this.storedLocation.top : this.element.getStyle("top"))
            } else {
                A += ",b:" + (this.storedLocation ? this.storedLocation.bottom : this.element.getStyle("bottom"))
            }
            A += "," + (this.storedLocation ? this.storedLocation.width : this.width);
            A += "," + (this.storedLocation ? this.storedLocation.height : this.height);
            A += "," + this.isMinimized();
            A += "," + this.isMaximized();
            WindowUtilities.setCookie(A, this.cookie)
        }
    },
    _createWiredElement: function() {
        if (!this.wiredElement) {
            if (Prototype.Browser.IE) {
                this._getWindowBorderSize()
            }
            var B = document.createElement("div");
            B.className = "wired_frame " + this.options.className + "_wired_frame";
            B.style.position = "absolute";
            this.options.parent.insertBefore(B, this.options.parent.firstChild);
            this.wiredElement = $(B)
        }
        if (this.useLeft) {
            this.wiredElement.setStyle({
                left: this.element.getStyle("left")
            })
        } else {
            this.wiredElement.setStyle({
                right: this.element.getStyle("right")
            })
        }
        if (this.useTop) {
            this.wiredElement.setStyle({
                top: this.element.getStyle("top")
            })
        } else {
            this.wiredElement.setStyle({
                bottom: this.element.getStyle("bottom")
            })
        }
        var A = this.element.getDimensions();
        this.wiredElement.setStyle({
            width: A.width + "px",
            height: A.height + "px"
        });
        this.wiredElement.setStyle({
            zIndex: Windows.maxZIndex + 30
        });
        return this.wiredElement
    },
    _hideWiredElement: function() {
        if (!this.wiredElement || !this.currentDrag) {
            return
        }
        if (this.currentDrag == this.element) {
            this.currentDrag = null
        } else {
            if (this.useLeft) {
                this.element.setStyle({
                    left: this.currentDrag.getStyle("left")
                })
            } else {
                this.element.setStyle({
                    right: this.currentDrag.getStyle("right")
                })
            }
            if (this.useTop) {
                this.element.setStyle({
                    top: this.currentDrag.getStyle("top")
                })
            } else {
                this.element.setStyle({
                    bottom: this.currentDrag.getStyle("bottom")
                })
            }
            this.currentDrag.hide();
            this.currentDrag = null;
            if (this.doResize) {
                this.setSize(this.width, this.height)
            }
        }
    },
    _notify: function(A) {
        if (this.options[A]) {
            this.options[A](this)
        } else {
            Windows.notify(A, this)
        }
    }
};
var Windows = {
    windows: [],
    modalWindows: [],
    observers: [],
    focusedWindow: null,
    maxZIndex: 0,
    overlayShowEffectOptions: {
        duration: 0.5
    },
    overlayHideEffectOptions: {
        duration: 0.5
    },
    addObserver: function(A) {
        this.removeObserver(A);
        this.observers.push(A)
    },
    removeObserver: function(A) {
        this.observers = this.observers.reject(function(B) {
            return B == A
        })
    },
    notify: function(A, B) {
        this.observers.each(function(C) {
            if (C[A]) {
                C[A](A, B)
            }
        })
    },
    getWindow: function(A) {
        return this.windows.detect(function(B) {
            return B.getId() == A
        })
    },
    getFocusedWindow: function() {
        return this.focusedWindow
    },
    updateFocusedWindow: function() {
        this.focusedWindow = this.windows.length >= 2 ? this.windows[this.windows.length - 2] : null
    },
    register: function(A) {
        this.windows.push(A)
    },
    addModalWindow: function(A) {
        if (this.modalWindows.length == 0) {
            WindowUtilities.disableScreen(A.options.className, "overlay_modal", A.overlayOpacity, A.getId(), A.options.parent)
        } else {
            if (Window.keepMultiModalWindow) {
                $("overlay_modal").style.zIndex = Windows.maxZIndex + 1;
                Windows.maxZIndex += 1;
                WindowUtilities._hideSelect(this.modalWindows.last().getId())
            } else {
                this.modalWindows.last().element.hide()
            }
            WindowUtilities._showSelect(A.getId())
        }
        this.modalWindows.push(A)
    },
    removeModalWindow: function(A) {
        this.modalWindows.pop();
        if (this.modalWindows.length == 0) {
            WindowUtilities.enableScreen()
        } else {
            if (Window.keepMultiModalWindow) {
                this.modalWindows.last().toFront();
                WindowUtilities._showSelect(this.modalWindows.last().getId())
            } else {
                this.modalWindows.last().element.show()
            }
        }
    },
    register: function(A) {
        this.windows.push(A)
    },
    unregister: function(A) {
        this.windows = this.windows.reject(function(B) {
            return B == A
        })
    },
    closeAll: function() {
        this.windows.each(function(A) {
            Windows.close(A.getId())
        })
    },
    closeAllModalWindows: function() {
        WindowUtilities.enableScreen();
        this.modalWindows.each(function(A) {
            if (A) {
                A.close()
            }
        })
    },
    minimize: function(C, A) {
        var B = this.getWindow(C);
        if (B && B.visible) {
            B.minimize()
        }
        Event.stop(A)
    },
    maximize: function(C, A) {
        var B = this.getWindow(C);
        if (B && B.visible) {
            B.maximize()
        }
        Event.stop(A)
    },
    close: function(C, A) {
        var B = this.getWindow(C);
        if (B) {
            B.close()
        }
        if (A) {
            Event.stop(A)
        }
    },
    blur: function(B) {
        var A = this.getWindow(B);
        if (!A) {
            return
        }
        if (A.options.blurClassName) {
            A.changeClassName(A.options.blurClassName)
        }
        if (this.focusedWindow == A) {
            this.focusedWindow = null
        }
        A._notify("onBlur")
    },
    focus: function(B) {
        var A = this.getWindow(B);
        if (!A) {
            return
        }
        if (this.focusedWindow) {
            this.blur(this.focusedWindow.getId())
        }
        if (A.options.focusClassName) {
            A.changeClassName(A.options.focusClassName)
        }
        this.focusedWindow = A;
        A._notify("onFocus")
    },
    unsetOverflow: function(A) {
        this.windows.each(function(B) {
            B.oldOverflow = B.getContent().getStyle("overflow") || "auto";
            B.getContent().setStyle({
                overflow: "hidden"
            })
        });
        if (A && A.oldOverflow) {
            A.getContent().setStyle({
                overflow: A.oldOverflow
            })
        }
    },
    resetOverflow: function() {
        this.windows.each(function(A) {
            if (A.oldOverflow) {
                A.getContent().setStyle({
                    overflow: A.oldOverflow
                })
            }
        })
    },
    updateZindex: function(A, B) {
        if (A > this.maxZIndex) {
            this.maxZIndex = A;
            if (this.focusedWindow) {
                this.blur(this.focusedWindow.getId())
            }
        }
        this.focusedWindow = B;
        if (this.focusedWindow) {
            this.focus(this.focusedWindow.getId())
        }
    }
};
var Dialog = {
    dialogId: null,
    onCompleteFunc: null,
    callFunc: null,
    parameters: null,
    confirm: function(D, C) {
        if (D && typeof D != "string") {
            Dialog._runAjaxRequest(D, C, Dialog.confirm);
            return
        }
        D = D || "";
        C = C || {};
        var F = C.okLabel ? C.okLabel : "Ok";
        var A = C.cancelLabel ? C.cancelLabel : "Cancel";
        C = Object.extend(C, C.windowParameters || {});
        C.windowParameters = C.windowParameters || {};
        C.className = C.className || "alert";
        var B = "class ='" + (C.buttonClass ? C.buttonClass + " " : "") + " ok_button'";
        var E = "class ='" + (C.buttonClass ? C.buttonClass + " " : "") + " cancel_button'";
        var D = "      <div class='" + C.className + "_message'>" + D + "</div>        <div class='" + C.className + "_buttons'>          <input type='button' value='" + F + "' onclick='Dialog.okCallback()' " + B + "/>          <input type='button' value='" + A + "' onclick='Dialog.cancelCallback()' " + E + "/>        </div>    ";
        return this._openDialog(D, C)
    },
    alert: function(C, B) {
        if (C && typeof C != "string") {
            Dialog._runAjaxRequest(C, B, Dialog.alert);
            return
        }
        C = C || "";
        B = B || {};
        var D = B.okLabel ? B.okLabel : "Ok";
        B = Object.extend(B, B.windowParameters || {});
        B.windowParameters = B.windowParameters || {};
        B.className = B.className || "alert";
        var A = "class ='" + (B.buttonClass ? B.buttonClass + " " : "") + " ok_button'";
        var C = "      <div class='" + B.className + "_message'>" + C + "</div>        <div class='" + B.className + "_buttons'>          <input type='button' value='" + D + "' onclick='Dialog.okCallback()' " + A + "/>        </div>";
        return this._openDialog(C, B)
    },
    info: function(B, A) {
        if (B && typeof B != "string") {
            Dialog._runAjaxRequest(B, A, Dialog.info);
            return
        }
        B = B || "";
        A = A || {};
        A = Object.extend(A, A.windowParameters || {});
        A.windowParameters = A.windowParameters || {};
        A.className = A.className || "alert";
        var B = "<div id='modal_dialog_message' class='" + A.className + "_message'>" + B + "</div>";
        if (A.showProgress) {
            B += "<div id='modal_dialog_progress' class='" + A.className + "_progress'>  </div>"
        }
        A.ok = null;
        A.cancel = null;
        return this._openDialog(B, A)
    },
    setInfoMessage: function(A) {
        $("modal_dialog_message").update(A)
    },
    closeInfo: function() {
        Windows.close(this.dialogId)
    },
    _openDialog: function(E, D) {
        var C = D.className;
        if (!D.height && !D.width) {
            D.width = WindowUtilities.getPageSize(D.options.parent || document.body).pageWidth / 2
        }
        if (D.id) {
            this.dialogId = D.id
        } else {
            var B = new Date();
            this.dialogId = "modal_dialog_" + B.getTime();
            D.id = this.dialogId
        }
        if (!D.height || !D.width) {
            var A = WindowUtilities._computeSize(E, this.dialogId, D.width, D.height, 5, C);
            if (D.height) {
                D.width = A + 5
            } else {
                D.height = A + 5
            }
        }
        D.effectOptions = D.effectOptions;
        D.resizable = D.resizable || false;
        D.minimizable = D.minimizable || false;
        D.maximizable = D.maximizable || false;
        D.draggable = D.draggable || false;
        D.closable = D.closable || false;
        var F = new Window(D);
        F.getContent().innerHTML = E;
        F.showCenter(true, D.top, D.left);
        F.setDestroyOnClose();
        F.cancelCallback = D.onCancel || D.cancel;
        F.okCallback = D.onOk || D.ok;
        return F
    },
    _getAjaxContent: function(A) {
        Dialog.callFunc(A.responseText, Dialog.parameters)
    },
    _runAjaxRequest: function(C, B, A) {
        if (C.options == null) {
            C.options = {}
        }
        Dialog.onCompleteFunc = C.options.onComplete;
        Dialog.parameters = B;
        Dialog.callFunc = A;
        C.options.onComplete = Dialog._getAjaxContent;
        new Ajax.Request(C.url, C.options)
    },
    okCallback: function() {
        var A = Windows.focusedWindow;
        if (!A.okCallback || A.okCallback(A)) {
            $$("#" + A.getId() + " input").each(function(B) {
                B.onclick = null
            });
            A.close()
        }
    },
    cancelCallback: function() {
        var A = Windows.focusedWindow;
        $$("#" + A.getId() + " input").each(function(B) {
            B.onclick = null
        });
        A.close();
        if (A.cancelCallback) {
            A.cancelCallback(A)
        }
    }
};
if (Prototype.Browser.WebKit) {
    var array = navigator.userAgent.match(new RegExp(/AppleWebKit\/([\d\.\+]*)/));
    Prototype.Browser.WebKitVersion = parseFloat(array[1])
}
var WindowUtilities = {
    getWindowScroll: function(parent) {
        var T, L, W, H;
        parent = parent || document.body;
        if (parent != document.body) {
            T = parent.scrollTop;
            L = parent.scrollLeft;
            W = parent.scrollWidth;
            H = parent.scrollHeight
        } else {
            var w = window;
            with(w.document) {
                if (w.document.documentElement && documentElement.scrollTop) {
                    T = documentElement.scrollTop;
                    L = documentElement.scrollLeft
                } else {
                    if (w.document.body) {
                        T = body.scrollTop;
                        L = body.scrollLeft
                    }
                }
                if (w.innerWidth) {
                    W = w.innerWidth;
                    H = w.innerHeight
                } else {
                    if (w.document.documentElement && documentElement.clientWidth) {
                        W = documentElement.clientWidth;
                        H = documentElement.clientHeight
                    } else {
                        W = body.offsetWidth;
                        H = body.offsetHeight
                    }
                }
            }
        }
        return {
            top: T,
            left: L,
            width: W,
            height: H
        }
    },
    getPageSize: function(D) {
        D = D || document.body;
        var C, G;
        var E, B;
        if (D != document.body) {
            C = D.getWidth();
            G = D.getHeight();
            B = D.scrollWidth;
            E = D.scrollHeight
        } else {
            var F, A;
            if (window.innerHeight && window.scrollMaxY) {
                F = document.body.scrollWidth;
                A = window.innerHeight + window.scrollMaxY
            } else {
                if (document.body.scrollHeight > document.body.offsetHeight) {
                    F = document.body.scrollWidth;
                    A = document.body.scrollHeight
                } else {
                    F = document.body.offsetWidth;
                    A = document.body.offsetHeight
                }
            }
            if (self.innerHeight) {
                C = self.innerWidth;
                G = self.innerHeight
            } else {
                if (document.documentElement && document.documentElement.clientHeight) {
                    C = document.documentElement.clientWidth;
                    G = document.documentElement.clientHeight
                } else {
                    if (document.body) {
                        C = document.body.clientWidth;
                        G = document.body.clientHeight
                    }
                }
            }
            if (A < G) {
                E = G
            } else {
                E = A
            }
            if (F < C) {
                B = C
            } else {
                B = F
            }
        }
        return {
            pageWidth: B,
            pageHeight: E,
            windowWidth: C,
            windowHeight: G
        }
    },
    disableScreen: function(C, A, D, E, B) {
        WindowUtilities.initLightbox(A, C, function() {
            this._disableScreen(C, A, D, E)
        }.bind(this), B || document.body)
    },
    _disableScreen: function(C, B, E, F) {
        var D = $(B);
        var A = WindowUtilities.getPageSize(D.parentNode);
        if (F && Prototype.Browser.IE) {
            WindowUtilities._hideSelect();
            WindowUtilities._showSelect(F)
        }
        D.style.height = (A.pageHeight + "px");
        D.style.display = "none";
        if (B == "overlay_modal" && Window.hasEffectLib && Windows.overlayShowEffectOptions) {
            D.overlayOpacity = E;
            new Effect.Appear(D, Object.extend({
                from: 0,
                to: E
            }, Windows.overlayShowEffectOptions))
        } else {
            D.style.display = "block"
        }
    },
    enableScreen: function(B) {
        B = B || "overlay_modal";
        var A = $(B);
        if (A) {
            if (B == "overlay_modal" && Window.hasEffectLib && Windows.overlayHideEffectOptions) {
                new Effect.Fade(A, Object.extend({
                    from: A.overlayOpacity,
                    to: 0
                }, Windows.overlayHideEffectOptions))
            } else {
                A.style.display = "none";
                A.parentNode.removeChild(A)
            }
            if (B != "__invisible__") {
                WindowUtilities._showSelect()
            }
        }
    },
    _hideSelect: function(A) {
        if (Prototype.Browser.IE) {
            A = A == null ? "" : "#" + A + " ";
            $$(A + "select").each(function(B) {
                if (!WindowUtilities.isDefined(B.oldVisibility)) {
                    B.oldVisibility = B.style.visibility ? B.style.visibility : "visible";
                    B.style.visibility = "hidden"
                }
            })
        }
    },
    _showSelect: function(A) {
        if (Prototype.Browser.IE) {
            A = A == null ? "" : "#" + A + " ";
            $$(A + "select").each(function(B) {
                if (WindowUtilities.isDefined(B.oldVisibility)) {
                    try {
                        B.style.visibility = B.oldVisibility
                    } catch (C) {
                        B.style.visibility = "visible"
                    }
                    B.oldVisibility = null
                } else {
                    if (B.style.visibility) {
                        B.style.visibility = "visible"
                    }
                }
            })
        }
    },
    isDefined: function(A) {
        return typeof(A) != "undefined" && A != null
    },
    initLightbox: function(E, C, A, B) {
        if ($(E)) {
            Element.setStyle(E, {
                zIndex: Windows.maxZIndex + 1
            });
            Windows.maxZIndex++;
            A()
        } else {
            var D = document.createElement("div");
            D.setAttribute("id", E);
            D.className = "overlay_" + C;
            D.style.display = "none";
            D.style.position = "absolute";
            D.style.top = "0";
            D.style.left = "0";
            D.style.zIndex = Windows.maxZIndex + 1;
            Windows.maxZIndex++;
            D.style.width = "100%";
            B.insertBefore(D, B.firstChild);
            if (Prototype.Browser.WebKit && E == "overlay_modal") {
                setTimeout(function() {
                    A()
                }, 10)
            } else {
                A()
            }
        }
    },
    setCookie: function(B, A) {
        document.cookie = A[0] + "=" + escape(B) + ((A[1]) ? "; expires=" + A[1].toGMTString() : "") + ((A[2]) ? "; path=" + A[2] : "") + ((A[3]) ? "; domain=" + A[3] : "") + ((A[4]) ? "; secure" : "")
    },
    getCookie: function(C) {
        var B = document.cookie;
        var E = C + "=";
        var D = B.indexOf("; " + E);
        if (D == -1) {
            D = B.indexOf(E);
            if (D != 0) {
                return null
            }
        } else {
            D += 2
        }
        var A = document.cookie.indexOf(";", D);
        if (A == -1) {
            A = B.length
        }
        return unescape(B.substring(D + E.length, A))
    },
    _computeSize: function(E, A, B, G, D, F) {
        var I = document.body;
        var C = document.createElement("div");
        C.setAttribute("id", A);
        C.className = F + "_content";
        if (G) {
            C.style.height = G + "px"
        } else {
            C.style.width = B + "px"
        }
        C.style.position = "absolute";
        C.style.top = "0";
        C.style.left = "0";
        C.style.display = "none";
        C.innerHTML = E;
        I.insertBefore(C, I.firstChild);
        var H;
        if (G) {
            H = $(C).getDimensions().width + D
        } else {
            H = $(C).getDimensions().height + D
        }
        I.removeChild(C);
        return H
    }
};

function dialog(B, A) {
    Dialog.info("", {
        showProgress: true,
        windowParameters: {
            title: A ? A : "Help",
            className: "popup",
            width: 500,
            height: 300,
            resizable: true,
            closable: true,
            draggable: true,
            zIndex: 2,
            url: BASE + "context/" + B
        }
    })
}
var UniProt = {};
var setSecurityDomain = function() {
    var A = /uniprot.org/;
    if (A.test(location.href)) {
        document.domain = "uniprot.org"
    }
};
UniProt.analytics = function analytics(B, C, A) {
    if (window._gaq !== undefined) {
        _gaq.push(["_trackEvent", B, C, A])
    }
};
Array.prototype.contains = function(B) {
    for (var A = 0; A < this.length; A++) {
        if (this[A] === B) {
            return true
        }
    }
    return false
};
Array.prototype.remove = function(B) {
    var C = false;
    for (var A = 0; A < this.length;
    A++) {
        if (this[A] === B) {
            this.splice(A, 1);
            C = true
        }
    }
    return C
};
Array.prototype.clear = function() {
    this.length = 0;
    return this
};
String.prototype.trim = function() {
    return this.replace(/^\s\s*/, "").replace(/\s\s*$/, "")
};
String.prototype.ltrim = function() {
    return this.replace(/^\s+/, "")
};
String.prototype.rtrim = function() {
    return this.replace(/\s+$/, "")
};

function addShowEvent(B) {
    var A = window.onpageshow;
    if (typeof window.onpageshow != "function") {
        window.onpageshow = B
    } else {
        window.onpageshow = function() {
            A();
            B()
        }
    }
}
function addHideEvent(B) {
    var A = window.onpagehide;
    if (typeof window.onpagehide != "function") {
        window.onpagehide = B
    } else {
        window.onpagehide = function() {
            A();
            B()
        }
    }
}
var domainUniprot;

function initDomainCart(A) {
    if (A != null && A != "") {
        domainUniprot = A
    }
}
function getCookie(C) {
    var D = document.cookie.indexOf(C + "=");
    var A = D + C.length + 1;
    if ((!D) && (C != document.cookie.substring(0, C.length))) {
        return null
    }
    if (D == -1) {
        return null
    }
    var B = document.cookie.indexOf(";", A);
    if (B == -1) {
        B = document.cookie.length
    }
    return unescape(document.cookie.substring(A, B))
}
function setCookie(C, E, H, A, D, G) {
    var B = new Date();
    B.setTime(B.getTime());
    if (A > 0) {
        A = A * 1000 * 60 * 60 * 24
    }
    var F = A >= 0 ? new Date(B.getTime() + (A)) : new Date(0);
    document.cookie = C + "=" + escape(E) + ((A) ? ";expires=" + F.toGMTString() : "") + ((H) ? ";path=" + H : "") + ((domainUniprot) ? ";domain=" + domainUniprot : "") + ((G) ? ";secure" : "")
}
function deleteCookie(A, C, B) {
    if (getCookie(A)) {
        if (C && C.charAt(0) != "/") {
            C = BASE + C + "/"
        }
        setCookie(A, "", C ? C : "/", -1, B)
    }
}
function save(A, B, C) {
    if (C && C.charAt(0) != "/") {
        C = BASE + C + "/"
    }
    setCookie(A, B, C ? C : "/", 365)
}
function save_tmp(A, B, C) {
    if (C && C.charAt(0) != "/") {
        C = BASE + C + "/"
    }
    setCookie(A, B, C ? C : "/")
}
function load(A) {
    return getCookie(A)
}
function ensureReferenceVisible(B) {
    var A = $(B);
    if (A == null) {
        return
    }
    UniProt.visibility.ensureSectionVisible(A);
    if (A.style.display == "none") {
        toggleLargeScale();
        $("large-scale-hide-link").hide();
        $("large-scale-show-link").show()
    }
}
function toggleLargeScale() {
    $("content-ref").select('input[id^="rp_"]').each(function(A) {
        var B = "ref" + A.id.substring(3);
        $(B).toggle()
    })
}
function ensureIsoformSequenceVisible(B) {
    var A = $(B);
    if (A == null) {
        return
    }
    UniProt.visibility.ensureSectionVisible(A);
    $(B + "-details").show();
    $(B + "-show-link").hide()
}
UniProt.UniProt = {};
UniProt.UniProt.linkTargets = {
    embl: "http://www.ebi.ac.uk/ena/data/view/",
    embl_cds: "http://www.ebi.ac.uk/ena/data/view/",
    genbank: "http://www.ncbi.nlm.nih.gov/entrez/viewer.fcgi?db=nuccore&id=",
    ddbj: "http://getentry.ddbj.nig.ac.jp/search/get_entry?accnumber=",
    genbank_cds: "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=protein&cmd=&term=",
    ddbj_cds: "http://srs.ddbj.nig.ac.jp/cgi-bin/wgetz?-e+[DADRELEASE:]",
    pdbe: "http://www.ebi.ac.uk/pdbe-srv/view/entry/",
    rcsb: "http://www.pdb.org/pdb/cgi/explore.cgi?pdbId=",
    pdbj: "http://service.pdbj.org/mine/Detail?PDBID="
};
UniProt.UniProt.display = {};
UniProt.UniProt.display.initLink = function(C) {
    var B = load(C + "-target");
    if (B) {
        UniProt.UniProt.configuredLinks[C] = B;
        var A = $(C + "-target-selector");
        if (A) {
            for (i = 0;
            i < A.options.length; ++i) {
                A.options[i].selected = A.options[i].value.toLowerCase() === B
            }
        }
        UniProt.UniProt.display.generate(C, B)
    }
};
UniProt.UniProt.display.movePageUpToAvoidTOC = function() {
    if (document.location.hash) {
        UniProt.TOC.determineHeight();
        UniProt.TOC.realMovePageUp(document.location.hash.substr(1))
    }
};
if (window.attachEvent) {
    window.attachEvent("hashchange", UniProt.UniProt.display.movePageUpToAvoidTOC, false)
} else {
    if (window.attachEventListener) {
        window.addEventListener("hashchange", UniProt.UniProt.display.movePageUpToAvoidTOC, false)
    }
}
UniProt.UniProt.configuredLinks = {
    insd: "embl",
    insd_cds: "embl_cds",
    pdb: "pdb"
};
UniProt.UniProt.display.configureLink = function(B, A) {
    if (B === "insd" || B === "insd_cds" || B === "pdb") {
        UniProt.UniProt.configuredLinks[B] = A;
        save(B + "-target", A, "uniprot");
        UniProt.UniProt.display.generate(B, A)
    }
};
UniProt.UniProt.display.generate = function(B, A) {
    if (B == "insd") {
        var D = $$("a.embl");
        for (var C = 0; C < D.length; ++C) {
            var E = D[C];
            E.href = E.href.replace(UniProt.UniProt.linkTargets.embl, UniProt.UniProt.linkTargets[A]);
            E.href = E.href.replace(UniProt.UniProt.linkTargets.genbank, UniProt.UniProt.linkTargets[A]);
            E.href = E.href.replace(UniProt.UniProt.linkTargets.ddbj, UniProt.UniProt.linkTargets[A])
        }
    } else {
        if (B == "insd_cds") {
            var D = $$("a.embl_cds");
            for (var C = 0; C < D.length; ++C) {
                var E = D[C];
                E.href = E.href.replace(UniProt.UniProt.linkTargets.embl_cds, UniProt.UniProt.linkTargets[A]);
                E.href = E.href.replace(UniProt.UniProt.linkTargets.genbank_cds, UniProt.UniProt.linkTargets[A]);
                E.href = E.href.replace(UniProt.UniProt.linkTargets.ddbj_cds, UniProt.UniProt.linkTargets[A])
            }
        } else {
            if (B == "pdb") {
                var D = $$("a.pdb");
                for (var C = 0; C < D.length; ++C) {
                    var E = D[C];
                    E.href = E.href.replace("&PAGEID=Summary", "");
                    E.href = E.href.replace(UniProt.UniProt.linkTargets.pdbe, UniProt.UniProt.linkTargets[A]);
                    E.href = E.href.replace(UniProt.UniProt.linkTargets.rcsb, UniProt.UniProt.linkTargets[A]);
                    E.href = E.href.replace(UniProt.UniProt.linkTargets.pdbj, UniProt.UniProt.linkTargets[A]);
                    if (A == "pdbj") {
                        E.href = E.href.concat("&PAGEID=Summary")
                    }
                }
            }
        }
    }
};
UniProt.UniProt.display.insertCommentCount = function(A) {
    new Ajax.Request(BASE + "uniprot/" + A + ".comco", {
        method: "get",
        onSuccess: function(C) {
            var B = C.responseText;
            if (B !== null) {
                $("commentLink").innerHTML = "Read comments (" + B + ") or add your own"
            }
        },
        onFailure: function() {}
    })
};

function openLink(B) {
    var C = $(B);
    var A = C.options[C.selectedIndex];
    if (A != "") {
        window.location = A.value;
        return false
    }
    return true
}
var checkJobStatus = function() {
    var A = window.location.href.substr(0, window.location.href.length - window.location.search.length);
    new Ajax.Request(A + ".stat", {
        method: "get",
        onSuccess: function(B) {
            if (B.responseText.match(/COMPLETED/)) {
                clearInterval(interval);
                window.location.reload()
            } else {
                if (B.responseText.match(/FAILED/)) {
                    clearInterval(interval);
                    window.location.reload()
                } else {
                    if (B.responseText.match(/CANCELLED/)) {
                        clearInterval(interval);
                        window.location.reload()
                    }
                }
            }
        },
        onFailure: function(B) {}
    })
};
var shiftPressed = false;
var ctrlPressed = false;

function keyDown(A) {
    if (document.all) {
        A = window.event
    }
    if (A.keyCode == 16) {
        shiftPressed = true
    } else {
        if (A.keyCode == 17) {
            ctrlPressed = true
        }
    }
}
function keyUp(A) {
    if (document.all) {
        A = window.event
    }
    if (A.keyCode == 16) {
        shiftPressed = false
    } else {
        if (A.keyCode == 17) {
            ctrlPressed = false
        }
    }
}
function isShiftPressed() {
    return shiftPressed
}
function isCtrlPressed() {
    return ctrlPressed
}
addHideEvent(function() {
    shiftPressed = false;
    ctrlPressed = false
});
addShowEvent(function() {
    ctrlPressed = false
});
var sequences = new Array();

function initCart() {
    var A = load("cart");
    if (A) {
        sequences = A.split(" ");
        refreshCart()
    } else {
        if (sequences.length > 0) {
            sequences.clear();
            refreshCart()
        }
    }
}
function refreshCart() {
    var H = document.createTextNode("" + sequences.length);
    var E = $("cart-count");
    if (E) {
        E.replaceChild(H, E.firstChild)
    }
    var G = $("cart-list");
    var C = 0;
    if (G) {
        var F = "";
        var B = false;
        if (sequences.length > 0) {
            for (var D = sequences.length - 1; D > -1;
            D--) {
                if (C < 4) {
                    F += "<strong>" + formatCartItem(sequences[D]) + "</strong><a onclick=\"addCart('" + sequences[D] + '\'); return false" href="#" class="hide"><img title="Drop" alt="Drop" src="' + image_x_inverse + '"></a> '
                } else {
                    if (!B) {
                        B = true;
                        F += "<span id='cart-show'><strong><a href='#' onclick='$(\"cart-all-ids\").show(); $(\"cart-show\").hide(); $(\"cart-hide\").show(); return false;'>More &raquo;</a></strong></span>";
                        F += "<span id='cart-all-ids' style='display:none;'>"
                    }
                    F += "<strong>" + formatCartItem(sequences[D]) + "</strong><a onclick=\"addCart('" + sequences[D] + '\'); return false" href="#" class="hide"><img title="Drop" alt="Drop" src="' + image_x_inverse + '"></a> '
                }
                C++
            }
            if (C >= 4) {
                F += "</span>";
                F += "<span id='cart-hide' style='display:none;'><strong><a href='#' onclick='$(\"cart-all-ids\").hide(); $(\"cart-show\").show(); $(\"cart-hide\").hide(); return false;'>&laquo; Hide</a></strong></span>"
            }
        }
        G.innerHTML = F
    }
    UniProt.visibility.setVisible("cart", sequences.length > 0);
    $("cart-align").disabled = sequences.length < 2;
    if (sequences.length != 1 && sequences.length < 500) {
        $("cart-blast").disabled = true
    } else {
        $("cart-blast").disabled = false
    }
    var A = document.getElementsByClassName("cart-item");
    for (var D = 0; D < A.length; ++D) {
        A[D].checked = sequences.contains(A[D].id.split("checkbox_")[1])
    }
}
function formatCartItemTitle(D, A) {
    var C = D.replace(/_(.+?)_$/, "").replace(/_(\d+)$/, "").replace(/\-\d+/, "");
    if (C.length == 6) {
        var B = "/uniprot/" + C + ".txt";
        new Ajax.Request(B, {
            method: "get",
            onSuccess: function(H) {
                var E = H.responseText || "no response text";
                var G = /^ID   ([A-Z\d_]+) (.+)/;
                var F = G.exec(E);
                document.getElementById("cartItem" + A).title = F[1]
            }
        })
    }
}
function formatCartItem(B, A) {
    return B.replace(/_(.+?)_$/, "[$1]").replace(/_(\d+)$/, ":$1")
}
function addCart(A) {
    if (sequences.contains(A)) {
        sequences.remove(A)
    } else {
        if (sequences.length < 200) {
            sequences.push(A)
        } else {
            alert("The cart supports upto 200 sequences at a time. Please remove entries before adding more.")
        }
    }
    setTimeout(refreshCart, 0);
    save_tmp("cart", sequences.join(" "))
}
function appendCart(F, E) {
    var C = new Array();
    var B = $$(".cart-item");
    for (var D = 0; D < B.length; ++D) {
        var A = B[D].id.split("_")[1];
        if (A == F) {
            C.push(A);
            fillCart(C);
            break
        } else {
            if (sequences.contains(A)) {
                C.clear()
            } else {
                C.push(A)
            }
        }
    }
}
function addOrAppendCart(B, A) {
    if (isShiftPressed()) {
        appendCart(B, A)
    } else {
        addCart(B)
    }
}
function addOrAppendCartMulti(D, A) {
    var C = D.split("%0A");
    var B = 0;
    while (B < C.length) {
        if (C[B].length != 0) {
            addOrAppendCart(C[B], A)
        }
        B++
    }
}
function fillCart(A) {
    var C = 0;
    for (var B = 0; B < A.length; ++B) {
        if (!sequences.contains(A[B])) {
            if (sequences.length < 200) {
                sequences.push(A[B])
            } else {
                alert("The cart supports upto 200 sequences at a time. Please remove entries before adding more.")
            }++C
        }
    }
    if (C > 0) {
        setTimeout(refreshCart, 0);
        save_tmp("cart", sequences.join(" "))
    }
}
function clearCart() {
    sequences.clear();
    refreshCart();
    deleteCookie("cart")
}
function submitCart() {
    var A = $("align-form");
    A.elements.query.value = getCartData();
    A.elements.redirect.value = isCtrlPressed() ? "no" : "yes";
    A.submit()
}
function fetchCart() {
    var A = $("batch-form");
    A.elements.query.value = getCartData();
    A.submit()
}
function blastCart() {
    var A = $("blast-form");
    A.elements.query.value = getCartData();
    A.submit()
}
function getCartData() {
    var B = "";
    for (var A = 0;
    A < sequences.length; A++) {
        B += formatCartItem(sequences[A]);
        B += "\n"
    }
    return B
}
addShowEvent(function(A) {
    if (A && A.persisted) {
        initCart()
    }
});

function toggle(B) {
    var A = $(B);
    if (A != null) {
        A.toggle()
    }
}
function showAll(B, E, C) {
    var D = document.getElementsByClassName(B, C);
    for (var A = 0; A < D.length; ++A) {
        UniProt.visibility.setVisible(D[A], E)
    }
}
setVisible = function(C, B) {
    var A = $(C);
    if (A != null) {
        B ? A.show() : A.hide()
    }
};
UniProt.visibility = {};
UniProt.visibility.orderCookie = "sections-order2";
UniProt.visibility.hiddenSections = [];
UniProt.visibility.setVisible = setVisible;
UniProt.visibility.setToggleText = function(A, B) {
    A.innerHTML = B ? "Hide" : "Show"
};
UniProt.visibility.setToggleTexts = function(A, B) {
    if (A) {
        A.classNames().each(function(C) {
            $$("." + C).each(function(D) {
                UniProt.visibility.setToggleText(D, !B)
            })
        })
    }
};
UniProt.visibility.setToggle = function(C, E, F, B) {
    var A = C.visible();
    C.toggle();
    if (C.id) {
        var D = C.hasClassName("hidden-default") ? A : !A;
        if (D) {
            UniProt.visibility.hiddenSections.remove(C.id)
        } else {
            if (!UniProt.visibility.hiddenSections.contains(C.id)) {
                UniProt.visibility.hiddenSections.push(C.id)
            }
        }
        if (UniProt.visibility.hiddenSections.length > 0) {
            save("sections-hide2", UniProt.visibility.hiddenSections.join(" "), B)
        } else {
            deleteCookie("sections-hide2", B)
        }
        UniProt.visibility.setToggleTexts(F, A)
    }
};
UniProt.visibility.setSectionContentsVisible = function(A, B) {
    UniProt.visibility.setVisible(A, B);
    $$(".toggle-" + A.id).each(function(C) {
        UniProt.visibility.setToggleText(C, B)
    })
};
UniProt.visibility.ensureSectionVisible = function(A) {
    if (A == null) {
        return
    }
    var B;
    if (A.hasClassName("nice")) {
        B = A.down(".nice-content")
    } else {
        if (!A.hasClassName("nice-content")) {
            B = A.up(".nice-content")
        } else {
            B = A
        }
    }
    if (A === undefined) {
        return
    }
    UniProt.visibility.setSectionContentsVisible(B, true)
};
UniProt.visibility.initSections = function(A) {
    if ($("sections") == null) {
        return
    }
    Sortable.create("sections", {
        tag: "div",
        constraint: "vertical",
        handle: "handle",
        scroll: window,
        onUpdate: function(D) {
            var E = $("sections").childNodes;
            var B = [];
            for (var C = 0; E.length > C; ++C) {
                if (E[C].id) {
                    B.push(E[C].id)
                }
            }
            if (B.length > 0) {
                save(UniProt.visibility.orderCookie, B.join(" "), A)
            } else {
                deleteCookie(UniProt.visibility.orderCookie, A)
            }
        }
    });
    UniProt.visibility.initHideSections();
    UniProt.visibility.initOrderSections()
};
UniProt.visibility.initHideSections = function() {
    var A = load("sections-hide2");
    if (A) {
        UniProt.visibility.hiddenSections = A.split(" ")
    } else {
        if (UniProt.visibility.hiddenSections.length > 0) {
            UniProt.visibility.hiddenSections.clear()
        }
    }
    UniProt.visibility.refreshSections()
};
UniProt.visibility.initOrderSections = function(F) {
    var C = load(F);
    if (C) {
        var E = C.split(" ");
        var B = $("sections");
        for (var A = E.length - 1; A > -1; --A) {
            var D = B.removeChild($(E[A]));
            if (D) {
                B.insertBefore(D, B.firstChild)
            }
        }
    }
};
UniProt.visibility.refreshSections = function() {
    var D = $$("div.nice-content");
    for (var A = 0; A < D.length; ++A) {
        var B = D[A];
        var C = !UniProt.visibility.hiddenSections.contains(D[A].id);
        if (B.hasClassName("hidden-default")) {
            C = !C
        }
        UniProt.visibility.setSectionContentsVisible(B, C)
    }
};
UniProt.visibility.saveSortOrder = function(E, D) {
    var C = $("sectionSortOrder").childNodes;
    var A = [];
    for (var B = 0; C.length > B; ++B) {
        if (C[B].value) {
            A.push(C[B].value)
        }
    }
    save(E, A.join(" "), D);
    location.reload();
    return false
};
var dims_helpContent = {
    ttDiv: "233",
    ttCont: "200",
    ttCross: "11"
};
var showHelp = function(C, D) {
    var B = Event.extend(C);
    var A = B.element();
    if (A.hasAttribute("class")) {
        new tooltip().show(B, A.readAttribute("class"), dims_helpContent)
    } else {
        fetchContent(C, D, true)
    }
};
var fetchContent = function(G, H, A) {
    var E = Event.extend(G);
    var B = E.element();
    var D = "";
    if (B.textContent) {
        D = B.textContent
    } else {
        if (B.innerText) {
            D = B.innerText
        }
    }
    var F = new RegExp("(.+)\\((.+)\\)");
    var C = "";
    C = BASE + "colheaders/" + H + ".json";
    UniProt.utilities.MakeAjaxCall(C, function(I) {
        var J = cleanHelpContents(I.content);
        B.writeAttribute("class", J);
        if (A) {
            new tooltip().show(E, J, dims_helpContent)
        }
    })
};
var showHelpAfterTimeOut = function(B, C) {
    var A = setTimeout(function() {
        clearInterval();
        showHelp(B, C)
    }, 1000);
    Event.extend(B).element().writeAttribute("id", A)
};

function cancelMouseOver(B) {
    var A = Event.extend(B).element();
    if (A.hasAttribute("id")) {
        clearTimeout(A.readAttribute("id"))
    }
}
function cleanHelpContents(A) {
    var B = new RegExp("<div><p>(.+)</p>(.*)</div>");
    return B.exec(A)[1]
}
function tooltip() {
    var C = null;
    var A = null;
    var F = null;
    var D = {
        minX: 2,
        minY: 2,
        zindex: 100,
        maxwidth: 200
    };

    function E(G, H) {
        if ($("ttdiv")) {
            C = $("ttdiv");
            A = $("ttcontent").update(G);
            F = $("ttcross")
        } else {
            C = $(document.createElement("div"));
            C.setAttribute("id", "ttdiv");
            if (H) {
                C.setAttribute("style", "width : " + H.ttDiv + "px")
            }
            A = $(document.createElement("div")).update(G);
            A.setAttribute("id", "ttcontent");
            if (H) {
                A.setAttribute("style", "width : " + H.ttCont + "px")
            }
            F = $(document.createElement("div")).update('<img src="/images/x_icon.gif" onclick="new tooltip().hide();"/>');
            F.setAttribute("id", "ttcross");
            if (H) {
                F.setAttribute("style", "width : " + H.ttCross + "px")
            }
            C.appendChild(A);
            C.appendChild(F);
            document.body.appendChild(C);
            Element.hide(C)
        }
    }
    function B(K) {
        var H = Event.pointerX(K);
        var G = Event.pointerY(K);
        var J = Element.getDimensions(C);
        var I = J.width;
        var L = J.height;
        if ((I + H + D.minX) >= (document.viewport.getWidth())) {
            H = H - I - D.minX
        } else {
            H = H + D.minX
        }
        if ((L + G + D.minY) >= (document.viewport.getHeight())) {
            G = G - L - D.minY
        } else {
            G = G + D.minY
        }
        Element.setStyle(C, {
            top: G + "px",
            left: H + "px"
        })
    }
    this.show = function(H, G, I) {
        E(G, I);
        B(H);
        Element.show(C)
    };
    this.hide = function() {
        if ($("ttdiv")) {
            $("ttdiv").hide()
        }
    }
}
UniProt.htmlUtils = {};
UniProt.utilities = {};
UniProt.htmlUtils = {
    addth: function(B, A) {
        return this.addElement(B, "th", A)
    },
    addtr: function(B, A) {
        return this.addElement(B, "tr", A)
    },
    addtd: function(B, A) {
        return this.addElement(B, "td", A)
    },
    addh2: function(B, A) {
        return this.addElement(B, "h2", A)
    },
    addDiv: function(B, A) {
        return this.addElement(B, "div", A)
    },
    addNewLine: function(A) {
        return this.addElement(A, "br")
    },
    addSpan: function(A, B) {
        return this.addElement(A, "span", {}, B)
    },
    addTable: function(B, A) {
        return this.addElement(B, "table", A)
    },
    addLabel: function(C, A, B) {
        return this.addElement(C, "p", A, B)
    },
    addRadio: function(B, A) {
        return this.addElement(B, "input", A)
    },
    addAcronym: function(C, A, B) {
        return this.addElement(C, "acronym", A, B)
    },
    addElement: function(E, A, B, D) {
        var C;
        if (B) {
            C = new Element(A, B)
        } else {
            C = new Element(A)
        }
        if (D) {
            C.update(D)
        }
        E.insert(C);
        return C
    },
    addSelect: function(B, A) {
        return this.addElement(B, "select", A)
    },
    addOption: function(C, A, B) {
        return this.addElement(C, "option", A, B)
    },
    addOptionGroup: function(C, A, B) {
        return this.addElement(C, "optgroup", A, B)
    }
};
UniProt.utilities.MakeAjaxCall = function(B, A) {
    new Ajax.Request(B, {
        method: "get",
        requestHeaders: {
            Accept: "application/json"
        },
        onSuccess: function(D) {
            var C = D.responseText;
            if (C != null) {
                A(C.evalJSON(true))
            }
        },
        onFailure: function() {}
    })
};

function loadEntryAsText(D) {
    if (D.length > 0) {
        var A = BASE + "uniprot/" + D + ".txt";
        var C = "";
        var B = new Ajax.Request(A, {
            method: "get",
            parameters: C,
            onComplete: showResponse
        })
    } else {
        document.forms["feedback-form"].elements.subject.value = "UniProtKB entry update request"
    }
}
function showResponse(B) {
    var A = B.status;
    if (A == 200) {
        var D = "";
        var E = B.responseText;
        document.forms["feedback-form"].elements.text.value = E;
        var G = new RegExp("^ID   .* Reviewed;");
        var F = G.test(E);
        var C = F ? "UniProtKB/Swiss-Prot" : "UniProtKB/TrEMBL";
        document.forms["feedback-form"].elements.subject.value = C + " " + document.forms["feedback-form"].elements.entry.value + " entry update request";
        if (!F) {
            D = '<label for="none"><span>&nbsp;</span></label>This is currently an unreviewed entry. We are going to update it and integrate it as a reviewed entry in UniProtKB/Swiss-Prot.<br/>'
        }
        D += '<label for="none"><span>&nbsp;</span></label>Please post your update in the text field below, or <a href="#" onclick="displayTextEntry();">load the entry</a> in text format and add your comment.';
        document.getElementById("additionalInfo").innerHTML = D
    } else {
        alert("Entry not found or problem during request.")
    }
}
function displayTextEntry() {
    var A = document.forms["feedback-form"].elements.text.value;
    if (A.length > 190000) {
        alert("Entry size too large to be submitted. Please use free comments.")
    } else {
        document.forms["feedback-form"].elements.message.value = A
    }
}
function resetText() {
    document.forms["feedback-form"].elements.message.value = ""
}
function replaceGraph(C) {
    Element.extend(C);
    var D = C.readAttribute("query");
    var B = D + "&format=graph";
    var A = document.getElementById("graph");
    Element.extend(A);
    if (typeof A != "undefined" && A != null) {
        Element.extend(A);
        new Ajax.Request(B, {
            method: "get",
            onSuccess: function(E) {
                A.update(E.responseText)
            },
            onFailure: function(E) {
                A.update(E.responseText)
            }
        })
    }
}
function recordLocation(B) {
    Element.extend(B);
    var D = B.id;
    if (location.hash.length > 0) {
        var A = location.hash.substring(1);
        var C = new RegExp("(" + D.substring(5) + ",)|(," + D.substring(5) + ")|(#" + D.substring(5) + ")", "g");
        if (!C.test(location.hash)) {
            location.hash = location.hash + "," + D.substring(5)
        }
    } else {
        location.hash = D.substring(5)
    }
}
function reopenLocation() {
    if (location.hash.length > 0) {
        var B = Element.extend(document.getElementById("content"));
        var D = new Element("p", {
            "class": "warn"
        });
        D.update("Please wait while rebuilding tree");
        B.insert(D, {
            position: Element.before
        });
        var A = location.hash.substring(1).split(",");
        while (A.length > 0) {
            var C = A.shift();
            if (A.length == 0) {
                reopenChild(C, true)
            } else {
                reopenChild(C, false)
            }
        }
        D.remove()
    }
}
function reopenChild(C, B) {
    var B = B;
    var A = Element.extend(document.getElementById("item-" + C));
    if (typeof A != "undefined" && A != null) {
        if (B) {
            replaceGraph(A)
        }
        insertChild(A, B)
    } else {
        window.setTimeout("reopenChild(" + C + "," + B + ")", 200)
    }
}
function insertChild(C, F) {
    var E = C.readAttribute("query");
    var G = C.readAttribute("id");
    G = G.substring(5);
    var B = E + "&format=browse-table";
    var A = Element.extend(document.getElementById("child-" + G));
    Element.extend(A);
    var D = Element.extend(document.getElementById("item-" + G));
    Element.extend(D);
    Element.extend(lastActive);
    if (lastActive != "") {
        lastActive.removeClassName("active")
    }
    if (D.hasClassName("closed") && !D.hasClassName("loaded")) {
        C.addClassName("fetching");
        new Ajax.Request(B, {
            method: "get",
            onSuccess: function(H) {
                A.update(H.responseText);
                initTree(A);
                treeToggle(D, "open");
                if (F) {
                    C.addClassName("active")
                }
                C.addClassName("loaded");
                C.removeClassName("fetching");
                lastActive = C
            },
            onFailure: function(H) {
                A.update('<li><p class="warn">Ajax loading failed for subnode <a href=' + E + "> the data is available here</a></p></li>");
                treeToggle(D, "open");
                lastActive = C
            }
        })
    } else {
        lastActive = C;
        treeToggle(D);
        if (F) {
            C.addClassName("active")
        }
    }
}
UniProt.BlastMenu = {};
UniProt.BlastMenu.programOptions = "";

function showBlastOptions() {
    $("blast-options-show").hide();
    $("blast-options-hide").show();
    $("blast-options").show();
    var B = $("blast-options").select("table.blast-options-table")[0].down(0);
    B.select("tr")[0].remove();
    if (B.select("tr").size() === 0) {
        var F = UniProt.htmlUtils.addtr(B);
        var E = UniProt.htmlUtils.addtd(F);
        UniProt.BlastMenu.addLabel(E, "Database");
        var H = UniProt.BlastMenu.addSelect(E, "dataset");
        var G = UniProt.htmlUtils.addOptionGroup(H, {
            label: "Protein Knowledgebase"
        });
        UniProt.BlastMenu.addOption(G, "uniprotkb", "UniProtKB");
        UniProt.BlastMenu.addOption(G, "uniprotkb_archaea", "&nbsp;&nbsp;...Archaea");
        UniProt.BlastMenu.addOption(G, "uniprotkb_bacteria", "&nbsp;&nbsp;...Bacteria");
        UniProt.BlastMenu.addOption(G, "uniprotkb_eukaryota", "&nbsp;&nbsp;...Eukaryota");
        UniProt.BlastMenu.addOption(G, "uniprotkb_arthropoda", "&nbsp;&nbsp;...Arthropoda");
        UniProt.BlastMenu.addOption(G, "uniprotkb_fungi", "&nbsp;&nbsp;...Fungi");
        UniProt.BlastMenu.addOption(G, "uniprotkb_human", "&nbsp;&nbsp;...Human");
        UniProt.BlastMenu.addOption(G, "uniprotkb_mammals", "&nbsp;&nbsp;...Mammals");
        UniProt.BlastMenu.addOption(G, "uniprotkb_nematoda", "&nbsp;&nbsp;...Nematoda");
        UniProt.BlastMenu.addOption(G, "uniprotkb_viridiplantae", "&nbsp;&nbsp;...Plants");
        UniProt.BlastMenu.addOption(G, "uniprotkb_rodents", "&nbsp;&nbsp;...Rodents");
        UniProt.BlastMenu.addOption(G, "uniprotkb_vertebrates", "&nbsp;&nbsp;...Vertebrates");
        UniProt.BlastMenu.addOption(G, "uniprotkb_viruses", "&nbsp;&nbsp;...Viruses");
        UniProt.BlastMenu.addOption(G, "uniprotkb_pdb", "&nbsp;&nbsp;...PDB");
        UniProt.BlastMenu.addOption(G, "uniprotkb_complete_microbial_proteomes", "&nbsp;&nbsp;...Complete microbial proteomes");
        UniProt.BlastMenu.addOption(G, "uniprotkb_swissprot", "UniProtKB/Swiss-Prot");
        var D = UniProt.htmlUtils.addOptionGroup(H, {
            label: "Sequence Clusters"
        });
        UniProt.BlastMenu.addOption(D, "UniRef100", "UniRef100");
        UniProt.BlastMenu.addOption(D, "UniRef90", "UniRef90");
        UniProt.BlastMenu.addOption(D, "UniRef50", "UniRef50");
        var A = UniProt.htmlUtils.addOptionGroup(H, {
            label: "Sequence archive"
        });
        UniProt.BlastMenu.addOption(A, "uniparc", "UniParc");
        for (var C = 0; C < UniProt.BlastMenu.programOptions.options.length;
        C++) {
            UniProt.BlastMenu.makeSelectField(UniProt.BlastMenu.programOptions.options[C], F)
        }
        if (window.reInitBlastForm !== undefined) {
            window.reInitBlastForm()
        }
    }
    save("blast-options", "show")
}
function hideBlastOptions() {
    $("blast-options-hide").hide();
    $("blast-options-show").show();
    $("blast-options").hide();
    deleteCookie("blast-options")
}
function initBlastOptions() {
    var A = function() {
        showBlastOptions()
    };
    UniProt.BlastMenu.LoadOptions.callbacks.push(A);
    UniProt.BlastMenu.LoadOptions.runner()
}
UniProt.BlastMenu.LoadOptions = {
    runner: function() {
        if ($("threshold1000") == undefined && UniProt.BlastMenu.programOptions === "") {
            UniProt.utilities.MakeAjaxCall(BASE + "blast/options/blastp", function(C) {
                UniProt.BlastMenu.programOptions = C;
                for (var B = 0; B < UniProt.BlastMenu.LoadOptions.callbacks.length; B++) {
                    UniProt.BlastMenu.LoadOptions.callbacks[B]()
                }
            })
        } else {
            for (var A = 0; A < UniProt.BlastMenu.LoadOptions.callbacks.length; A++) {
                UniProt.BlastMenu.LoadOptions.callbacks[A]()
            }
        }
    },
    callbacks: []
};
UniProt.BlastMenu.makeSelectField = function(D, C) {
    var B = UniProt.htmlUtils.addtd(C);
    UniProt.BlastMenu.addLabel(B, D.display);
    var A = UniProt.BlastMenu.addSelect(B, D.name);
    D.values.each(function(E) {
        if (E.def === "false") {
            UniProt.BlastMenu.addOption(A, E.val, E.display)
        } else {
            UniProt.BlastMenu.addOption(A, E.val, E.display, true)
        }
    })
};
UniProt.BlastMenu.addLabel = function addLabel(C, A) {
    var B = UniProt.htmlUtils.addLabel(C, {
        "class": "label"
    });
    UniProt.htmlUtils.addAcronym(B, {
        onclick: "dialog('sequence-searches|blast-" + A.toLowerCase() + "')"
    }, A)
};
UniProt.BlastMenu.addSelect = function addSelect(C, A) {
    var B = UniProt.htmlUtils.addLabel(C);
    return UniProt.htmlUtils.addSelect(B, {
        name: A
    })
};
UniProt.BlastMenu.addOption = function addOption(E, D, C, A) {
    var B = {
        value: D
    };
    if (E.match("select")) {
        B.id = E.name + D
    } else {
        B.id = E.ancestors()[0].name + D
    }
    if (A === true) {
        B.selected = "selected"
    }
    return UniProt.htmlUtils.addOption(E, B, C)
};
UniProt.addOptionGroup = function addOptionGroup(B, A, D, F) {
    var E = Builder.node("optgroup", {
        label: B
    });
    for (var C = 0; C < A.length; ++C) {
        if (!A[C].hasOwnProperty("from") || A[C].from === F) {
            E.appendChild(Builder.node("option", {
                value: A[C].value
            }, A[C].label))
        }
    }
    D.appendChild(E)
};
UniProt.mappingOptions = function mappingOptions() {
    var A = function(E) {
        if (!E.empty()) {
            E.firstDescendant().remove()
        }
    };
    var D = function(F, E) {
        for (var G = 0; G < UniProt.mappingBuilders.length; ++G) {
            UniProt.addOptionGroup(UniProt.mappingBuilders[G].label, UniProt.mappingBuilders[G].members, F, E)
        }
    };
    var C = $("map-from");
    var B = $("map-to");
    A(C);
    A(B);
    D(C, true);
    D(B, false);
    UniProt.mappingSelected()
};
UniProt.mappingSelected = function mappingSelected() {
    var B = 5;
    var A = 0;
    var D = document.getElementById("map-from-label").getAttribute("from");
    var C = document.getElementById("map-to-label").getAttribute("to");
    if (typeof D === "string" && D !== "") {
        D = D.replace(/\s/, "+");
        B = UniProt.mappingFindSelected(true, D)
    }
    if (typeof C === "string" && C !== "") {
        A = UniProt.mappingFindSelected(false, C)
    }
    document.getElementById("map-from").options[B].selected = true;
    document.getElementById("map-to").options[A].selected = true
};
UniProt.mappingFindSelected = function mappingFindSelected(B, G) {
    var A = -1;
    var F = -1;
    for (var D = 0; D < UniProt.mappingBuilders.length; ++D) {
        for (var C = 0; C < UniProt.mappingBuilders[D].members.length; ++C) {
            var E = UniProt.mappingBuilders[D].members[C];
            if (!E.hasOwnProperty("from") || E.from === B) {
                A++
            }
            if (E.value === G) {
                F = A
            }
        }
    }
    return F
};
UniProt.mappingFaq = function mappingSelected() {
    var F = document.getElementById("mapping-faq-table");
    for (var E = 0; E < UniProt.mappingBuilders.length; ++E) {
        var B = new Element("th", {
            colspan: "3"
        });
        B.update(UniProt.mappingBuilders[E].label);
        F.appendChild(B);
        for (var C = 0; C < UniProt.mappingBuilders[E].members.length; ++C) {
            var D = UniProt.mappingBuilders[E].members[C];
            var G = new Element("tr");
            var A = new Element("td");
            var H = new Element("td");
            A.update(D.label);
            H.update(D.value);
            G.appendChild(A);
            G.appendChild(H);
            var I = new Element("td");
            if (D.hasOwnProperty("from")) {
                if (D.from) {
                    I.update("from")
                } else {
                    I.update("to")
                }
            } else {
                I.update("both")
            }
            G.appendChild(I);
            F.appendChild(G)
        }
    }
};
UniProt.mappingBuilders = [{
    label: "UniProt",
    members: [{
        value: "ACC+ID",
        label: "UniProtKB AC/ID",
        from: true
    }, {
        value: "ACC",
        label: "UniProtKB AC",
        from: false
    }, {
        value: "ID",
        label: "UniProtKB ID",
        from: false
    }, {
        value: "UPARC",
        label: "UniParc"
    }, {
        value: "NF50",
        label: "UniRef50"
    }, {
        value: "NF90",
        label: "UniRef90"
    }, {
        value: "NF100",
        label: "UniRef100"
    }]
}, {
    label: "Other sequence databases",
    members: [{
        value: "EMBL_ID",
        label: "EMBL/GenBank/DDBJ"
    }, {
        value: "EMBL",
        label: "EMBL/GenBank/DDBJ CDS"
    }, {
        value: "PIR",
        label: "PIR"
    }, {
        value: "UNIGENE_ID",
        label: "UniGene"
    }, {
        value: "P_ENTREZGENEID",
        label: "Entrez Gene (GeneID)"
    }, {
        value: "P_GI",
        label: "GI number*"
    }, {
        value: "P_IPI",
        label: "IPI"
    }, {
        value: "P_REFSEQ_AC",
        label: "RefSeq Protein"
    }, {
        value: "REFSEQ_NT_ID",
        label: "RefSeq Nucleotide"
    }]
}, {
    label: "3D structure databases",
    members: [{
        value: "PDB_ID",
        label: "PDB"
    }, {
        value: "DISPROT_ID",
        label: "DisProt"
    }, {
        value: "HSSP_ID",
        label: "HSSP"
    }]
}, {
    label: "Protein-protein interaction databases",
    members: [{
        value: "DIP_ID",
        label: "DIP"
    }, {
        value: "MINT_ID",
        label: "MINT"
    }]
}, {
    label: "Protein family/group databases",
    members: [{
        value: "ALLERGOME_ID",
        label: "Allergome"
    }, {
        value: "MEROPS_ID",
        label: "MEROPS"
    }, {
        value: "PEROXIBASE_ID",
        label: "PeroxiBase"
    }, {
        value: "PPTASEDB_ID",
        label: "PptaseDB"
    }, {
        value: "REBASE_ID",
        label: "REBASE"
    }, {
        value: "TCDB_ID",
        label: "TCDB"
    }]
}, {
    label: "PTM databases",
    members: [{
        value: "PHOSSITE_ID",
        label: "PhosSite"
    }]
}, {
    label: "Polymorphism databases",
    members: [{
        value: "DMDM_ID",
        label: "DMDM"
    }]
}, {
    label: "2D gel databases",
    members: [{
        value: "AARHUS_GHENT_2DPAGE_ID",
        label: "Aarhus/Ghent-2DPAGE"
    }, {
        value: "WORLD_2DPAGE_ID",
        label: "World-2DPAGE"
    }]
}, {
    label: "Protocols and materials databases",
    members: [{
        value: "DNASU_ID",
        label: "DNASU"
    }]
}, {
    label: "Genome annotation databases",
    members: [{
        value: "ENSEMBL_ID",
        label: "Ensembl"
    }, {
        value: "ENSEMBL_PRO_ID",
        label: "Ensembl Protein"
    }, {
        value: "ENSEMBL_TRS_ID",
        label: "Ensembl Transcript"
    }, {
        value: "ENSEMBLGENOME_ID",
        label: "Ensembl Genomes"
    }, {
        value: "ENSEMBLGENOME_PRO_ID",
        label: "Ensembl Genomes Protein"
    }, {
        value: "ENSEMBLGENOME_TRS_ID",
        label: "Ensembl Genomes Transcript"
    }, {
        value: "P_ENTREZGENEID",
        label: "GeneID"
    }, {
        value: "GENOMEREVIEWS_ID",
        label: "GenomeReviews"
    }, {
        value: "KEGG_ID",
        label: "KEGG"
    }, {
        value: "PATRIC_ID",
        label: "PATRIC"
    }, {
        value: "UCSC_ID",
        label: "UCSC"
    }, {
        value: "VECTORBASE_ID",
        label: "VectorBase"
    }]
}, {
    label: "Organism-specific gene databases",
    members: [{
        value: "AGD_ID",
        label: "AGD"
    }, {
        value: "ARACHNOSERVER_ID",
        label: "ArachnoServer"
    }, {
        value: "CGD",
        label: "CGD"
    }, {
        value: "CONOSERVER_ID",
        label: "ConoServer"
    }, {
        value: "CYGD_ID",
        label: "CYGD"
    }, {
        value: "DICTYBASE_ID",
        label: "dictyBase"
    }, {
        value: "ECHOBASE_ID",
        label: "EchoBASE"
    }, {
        value: "ECOGENE_ID",
        label: "EcoGene"
    }, {
        value: "EUHCVDB_ID",
        label: "euHCVdb"
    }, {
        value: "EUPATHDB_ID",
        label: "EuPathDB"
    }, {
        value: "FLYBASE_ID",
        label: "FlyBase"
    }, {
        value: "GENECARDS_ID",
        label: "GeneCards"
    }, {
        value: "GENEFARM_ID",
        label: "GeneFarm"
    }, {
        value: "GENOLIST_ID",
        label: "GenoList"
    }, {
        value: "H_INVDB_ID",
        label: "H-InvDB"
    }, {
        value: "HGNC_ID",
        label: "HGNC"
    }, {
        value: "HPA_ID",
        label: "HPA"
    }, {
        value: "LEGIOLIST_ID",
        label: "LegioList"
    }, {
        value: "LEPROMA_ID",
        label: "Leproma"
    }, {
        value: "MAIZEGDB_ID",
        label: "MaizeGDB"
    }, {
        value: "MIM_ID",
        label: "MIM"
    }, {
        value: "MGI_ID",
        label: "MGI"
    }, {
        value: "NEXTPROT_ID",
        label: "neXtProt"
    }, {
        value: "ORPHANET_ID",
        label: "Orphanet"
    }, {
        value: "PHARMGKB_ID",
        label: "PharmGKB"
    }, {
        value: "POMBASE_ID",
        label: "PomBase"
    }, {
        value: "PSEUDOCAP_ID",
        label: "PseudoCAP"
    }, {
        value: "RGD_ID",
        label: "RGD"
    }, {
        value: "SGD_ID",
        label: "SGD"
    }, {
        value: "TAIR_ID",
        label: "TAIR"
    }, {
        value: "TUBERCULIST_ID",
        label: "TubercuList"
    }, {
        value: "WORMBASE_ID",
        label: "WormBase"
    }, {
        value: "WORMBASE_TRS_ID",
        label: "WormBase Transcript"
    }, {
        value: "WORMBASE_PRO_ID",
        label: "WormBase Protein"
    }, {
        value: "XENBASE_ID",
        label: "Xenbase"
    }, {
        value: "ZFIN_ID",
        label: "ZFIN"
    }]
}, {
    label: "Phylogenomic databases",
    members: [{
        value: "EGGNOG_ID",
        label: "eggNOG"
    }, {
        value: "GENETREE_ID",
        label: "GeneTree"
    }, {
        value: "HOGENOM_ID",
        label: "HOGENOM"
    }, {
        value: "HOVERGEN_ID",
        label: "HOVERGEN"
    }, {
        value: "KO_ID",
        label: "KO"
    }, {
        value: "OMA_ID",
        label: "OMA"
    }, {
        value: "ORTHODB_ID",
        label: "OrthoDB"
    }, {
        value: "PROTCLUSTDB_ID",
        label: "ProtClustDB"
    }]
}, {
    label: "Enzyme and pathway databases",
    members: [{
        value: "BIOCYC_ID",
        label: "BioCyc"
    }, {
        value: "REACTOME_ID",
        label: "Reactome"
    }, {
        value: "UNIPATHWAY_ID",
        label: "UniPathWay"
    }]
}, {
    label: "Gene expression databases",
    members: [{
        value: "CLEANEX_ID",
        label: "CleanEx"
    }, {
        value: "GERMONLINE_ID",
        label: "GermOnline"
    }]
}, {
    label: "Other",
    members: [{
        value: "CHEMBL",
        label: "ChEMBL"
    }, {
        value: "DRUGBANK_ID",
        label: "DrugBank"
    }, {
        value: "GENOMERNAI_ID",
        label: "GenomeRNAi"
    }, {
        value: "NEXTBIO_ID",
        label: "NextBio"
    }]
}];
UniProt.help = function(B, A) {
    url = "/helpfloatover/?query=*&format=json"
};
var builderNodes = new Array();
var builderNode;
var submitNode;
var builder;
var FieldBuilder = Class.create({
    addPart: function(F, C, D) {
        var A = Builder.node("td");
        builderNodes.push(A);
        if (submitNode) {
            C.insertBefore(A, submitNode)
        } else {
            C.appendChild(A)
        }
        var E = Builder.node("p", {
            className: "label"
        }, F);
        A.appendChild(E);
        var B = Builder.node("p");
        A.appendChild(B);
        D(this, B)
    },
    quote: function(A) {
        if (this.id.length > 0 && A.indexOf(" ") != -1) {
            A = '"' + A + '"'
        }
        return A
    },
    prefix: function(A) {
        if (this.id.length > 0 && this.id != "content" && A.length > 0) {
            A = this.getFieldName() + ":" + A
        }
        return A
    },
    getFieldName: function() {
        s = this.id;
        if (s.length > 0 && s.indexOf(".") != -1) {
            s = s.substring(0, s.indexOf("."))
        }
        return s
    },
    postprocess: function(A) {
        return A
    }
});
var TextFieldBuilder = Class.create(FieldBuilder, {
    initialize: function(C, A, B) {
        this.id = C;
        this.label = A;
        this.size = B ? B : 41
    },
    render: function(A, B) {
        this.addPart(B ? this.label : "Term", A, function(C, D) {
            C.inputElem = document.createElement("input");
            C.inputElem.setAttribute("type", "text");
            C.inputElem.setAttribute("size", C.size);
            D.appendChild(C.inputElem)
        })
    },
    build: function() {
        return this.prefix(this.quote(this.inputElem.value))
    },
    activate: function(A) {
        this.inputElem.value = A;
        this.inputElem.focus()
    },
    deactivate: function() {
        return this.inputElem.value
    }
});
var SubQueryTextFieldBuilder = Class.create(TextFieldBuilder, {
    build: function() {
        return this.getFieldName() + ":(" + this.quote(this.inputElem.value) + ")"
    }
});
Http = new Object();
Http.Autocompleter = Class.create(Autocompleter.Base, {
    initialize: function(B, D, C, A) {
        this.baseInitialize(B, D, A);
        this.options.method = "get";
        this.options.asynchronous = true;
        this.options.indicator = A.indicator || "autocomplete-indicator";
        this.options.onComplete = this.onComplete.bind(this);
        this.url_template = C
    },
    getUpdatedChoices: function() {
        this.startIndicator();
        var A = encodeURIComponent(this.getToken());
        new Ajax.Request(this.expand_uri(this.url_template, {
            query: A
        }), this.options)
    },
    onComplete: function(A) {
        this.updateChoices(A.responseText)
    },
    expand_uri: function(D, G) {
        var F = D.match(/{[^}]+}/g);
        if (!F) {
            return D
        }
        for (var A = 0; A < F.length; A++) {
            var B = /{([^}]+)}/.exec(F[A])[1];
            var E = G[B];
            var C = new RegExp("{" + B + "}");
            D = D.replace(C, E)
        }
        return D
    }
});
var AutoCompleteFieldBuilder = Class.create(FieldBuilder, {
    initialize: function(D, A, B, C) {
        this.id = D;
        this.label = A;
        this.namespace = B;
        this.field = C
    },
    render: function(A, B) {
        this.addPart(B ? this.label : "Term", A, function(C, E) {
            var D = Builder.node("input", {
                id: "autocomplete-target",
                type: "text",
                size: 42
            });
            C.inputElem = D;
            E.appendChild(C.inputElem);
            var F = Builder.node("div", {
                id: "autocomplete-choices",
                "class": "autocomplete-choices"
            }, " ");
            $("content").appendChild(F);
            E.appendChild(Builder.node("span", {
                style: "position: relative;"
            }, [Builder.node("img", {
                src: BASE + "images/progress_inactive.gif",
                alt: "",
                title: "Ready for auto-completion",
                style: "position: absolute; left: -20px; top: 0.1em;"
            }), Builder.node("img", {
                id: "autocomplete-indicator",
                src: BASE + "images/progress.gif",
                alt: "",
                title: "Running auto-completion...",
                style: "position: absolute; left: -20px; top: 0.1em; display: none"
            })]));
            new Http.Autocompleter(D, F, BASE + "hints/" + C.namespace + "/?format=html&limit=100&sort=score&query=" + (C.field ? C.field + ":" : "") + "{query}", {
                minChars: 2
            })
        })
    },
    build: function() {
        return this.prefix(this.quote(this.inputElem.value))
    },
    activate: function(A) {
        this.inputElem.value = A;
        this.inputElem.focus()
    },
    deactivate: function() {
        return this.inputElem.value
    }
});
var LocalAutoCompleteFieldBuilder = Class.create(FieldBuilder, {
    initialize: function(C, A, B) {
        this.id = C;
        this.label = A;
        this.choices = B
    },
    render: function(A, B) {
        this.addPart(B ? this.label : "Term", A, function(C, D) {
            C.inputElem = Builder.node("input", {
                id: "autocomplete-target",
                type: "text",
                size: 42
            });
            D.appendChild(C.inputElem);
            D.appendChild(Builder.node("div", {
                id: "autocomplete-choices",
                "class": "autocomplete-choices"
            }, " "));
            new Autocompleter.Local("autocomplete-target", "autocomplete-choices", C.choices, {
                minChars: 1
            })
        })
    },
    build: function() {
        return this.prefix(this.quote(this.inputElem.value))
    },
    activate: function(A) {
        this.inputElem.value = A;
        this.inputElem.focus()
    },
    deactivate: function() {
        return this.inputElem.value
    }
});
var ListFieldBuilder = Class.create(FieldBuilder, {
    initialize: function(D, B, A, C) {
        this.id = D;
        this.label = B;
        this.values = A;
        this.labels = C
    },
    render: function(A, B) {
        this.addPart(B ? this.label : "Choose", A, function(C, F) {
            C.selectElem = document.createElement("select");
            var E = C.selectElem;
            for (var D = 0; D < C.values.length; ++D) {
                if (C.values[D] == null) {
                    E = document.createElement("optgroup");
                    E.setAttribute("label", C.labels[D]);
                    C.selectElem.appendChild(E)
                } else {
                    addOption(C.values[D], C.labels[D], E)
                }
            }
            C.selectElem.selectedIndex = 0;
            F.appendChild(C.selectElem)
        })
    },
    build: function() {
        return this.prefix(this.quote(this.selectElem.value))
    }
});
var MapFieldBuilder = Class.create(FieldBuilder, {
    initialize: function(C, A, B) {
        this.id = C;
        this.label = A;
        this.map = B
    },
    render: function(A, B) {
        this.addPart(B ? this.label : "Choose", A, function(C, H) {
            C.selectElem = document.createElement("select");
            var F = C.selectElem;
            for (var E = 0; E < C.map.length; ++E) {
                var G = "";
                if (C.map[E].label) {
                    G = UniProt.htmlUtils.addOptionGroup(C.selectElem, {
                        label: C.map[E].label
                    })
                }
                for (var D = 0; D < C.map[E].selects.length; ++D) {
                    if (G != "") {
                        addOption(C.map[E].selects[D].value, C.map[E].selects[D].label, G)
                    } else {
                        addOption(C.map[E].selects[D].value, C.map[E].selects[D].label, C.selectElem)
                    }
                }
            }
            C.selectElem.selectedIndex = 0;
            H.appendChild(C.selectElem)
        })
    },
    build: function() {
        return this.prefix(this.quote(this.selectElem.value))
    }
});

function BooleanFieldBuilder(B, A) {
    return new ListFieldBuilder(B, A, ["yes", "no"], ["yes", "no"])
}
var RangeFieldBuilder = Class.create(FieldBuilder, {
    initialize: function(B, A) {
        this.id = B;
        this.label = A
    },
    render: function(A, B) {
        this.addPart(B ? this.label : "From", A, function(C, D) {
            C.fromElem = document.createElement("input");
            C.fromElem.setAttribute("type", "text");
            C.fromElem.setAttribute("size", "7");
            D.appendChild(C.fromElem);
            D.appendChild(document.createTextNode(" \u2013"))
        });
        this.addPart(B ? "" : "To", A, function(C, D) {
            C.toElem = document.createElement("input");
            C.toElem.setAttribute("type", "text");
            C.toElem.setAttribute("size", "7");
            D.appendChild(C.toElem)
        })
    },
    build: function() {
        var B = this.fromElem.value.length > 0 ? this.fromElem.value : "*";
        var A = this.toElem.value.length > 0 ? this.toElem.value : "*";
        return (B != "*" || A != "*") ? this.prefix("[" + B + " TO " + A + "]") : ""
    }
});
var DateRangeFieldBuilder = Class.create(FieldBuilder, {
    initialize: function(B, A) {
        this.id = B;
        this.label = A
    },
    render: function(A, B) {
        builder.label = document.createElement("acronym");
        builder.label.setAttribute("onclick", "dialog('27')");
        builder.label.appendChild(document.createTextNode("From"));
        this.addPart(B ? this.label : builder.label, A, function(D, E) {
            D.fromElem = document.createElement("input");
            D.fromElem.setAttribute("type", "text");
            D.fromElem.setAttribute("size", "14");
            var C = new DateBocks({
                dateBocksElement: D.fromElem
            });
            D.fromElem.onchange = function() {
                C.magicDate()
            };
            D.fromElem.onkeypress = function(F) {
                C.keyObserver(F, "parse");
                return C.keyObserver(F, "return")
            };
            E.appendChild(D.fromElem)
        });
        builder.label = document.createElement("acronym");
        builder.label.setAttribute("onclick", "dialog('27')");
        builder.label.appendChild(document.createTextNode("To"));
        this.addPart(B ? "..." : builder.label, A, function(D, E) {
            D.toElem = document.createElement("input");
            D.toElem.setAttribute("type", "text");
            D.toElem.setAttribute("size", "14");
            var C = new DateBocks({
                dateBocksElement: D.toElem
            });
            D.toElem.onchange = function() {
                C.magicDate()
            };
            D.toElem.onkeypress = function(F) {
                C.keyObserver(F, "parse");
                return C.keyObserver(F, "return")
            };
            E.appendChild(D.toElem)
        })
    },
    build: function() {
        var B = this.fromElem.value.length > 0 ? this.fromElem.value : "*";
        var A = this.toElem.value.length > 0 ? this.toElem.value : "*";
        return (B != "*" || A != "*") ? this.prefix("[" + B + " TO " + A + "]") : ""
    }
});
var MultiFieldBuilder = Class.create(FieldBuilder, {
    initialize: function(C, A, B) {
        this.id = C;
        this.label = A;
        this.builders = B;
        if (arguments.length == 4) {
            this.prefixWithField = arguments[3]
        } else {
            this.prefixWithField = true
        }
    },
    render: function(B) {
        for (var A = 0; A < this.builders.length; ++A) {
            if (this.builders[A]) {
                this.builders[A].render(B, true)
            }
        }
    },
    build: function() {
        var C = "";
        for (var A = 0; A < this.builders.length; ++A) {
            if (this.builders[A]) {
                var B = this.builders[A].build();
                if (B) {
                    if (C.length == 0) {
                        C += this.getFieldName() + ":("
                    } else {
                        C += " "
                    }
                    C += B
                }
            }
        }
        if (C.length > 0) {
            C += ")"
        }
        return this.postprocess(C)
    },
    activate: function(B) {
        for (var A = 0; A < this.builders.length; ++A) {
            if (this.builders[A] && this.builders[A].activate) {
                this.builders[A].activate(B);
                break
            }
        }
    },
    deactivate: function() {
        for (var A = 0; A < this.builders.length; ++A) {
            if (this.builders[A] && this.builders[A].deactivate) {
                return this.builders[A].deactivate()
            }
        }
        return ""
    }
});
var IndexSelectFieldBuilder = Class.create(FieldBuilder, {
    initialize: function(C, A, B) {
        this.id = C;
        this.label = A;
        this.list_builder = B;
        this.query_builder = new TextFieldBuilder("content", "Term")
    },
    render: function(A) {
        this.list_builder.render(A, true);
        this.query_builder.render(A, true)
    },
    build: function() {
        var B = this.query_builder.build() || "*";
        var A = this.list_builder.build() + ":" + B;
        return this.postprocess(A)
    },
    activate: function(A) {
        if (this.list_builder.activate) {
            this.list_builder.activate(A)
        } else {
            if (this.query_builder.activate) {
                this.query_builder.activate(A)
            }
        }
    },
    deactivate: function() {
        if (this.list_builder.deactivate) {
            this.list_builder.deactivate(term)
        } else {
            if (this.query_builder.deactivate) {
                this.query_builder.deactivate(term)
            }
        }
    }
});
var builders = {
    uniprot: [new TextFieldBuilder("content", "All"), "", new TextFieldBuilder("name", "Protein name [DE]"), new TextFieldBuilder("gene", "Gene name [GN]"), new TextFieldBuilder("family", "Protein family"), new TextFieldBuilder("domain", "Domain"), "", new AutoCompleteFieldBuilder("organism", "Organism [OS]", "taxonomy", "annotated:yes content"), new AutoCompleteFieldBuilder("taxonomy", "Taxonomy [OC]", "taxonomy"), new AutoCompleteFieldBuilder("host", "Virus host [OH]", "taxonomy"), new LocalAutoCompleteFieldBuilder("organelle", "Organelle", ["Mitochondrion", "Plastid", "Chloroplast", "Cyanelle", "Apicoplast", "Organellar chromatophore", "Non-photosynthetic plastid", "Nucleomorph", "Hydrogenosome"]), "", new MultiFieldBuilder("annotation.nonpositional", "General annotation [CC]", [new MapFieldBuilder("type", "Topic", CCDropDownOptions), new TextFieldBuilder("content", "Term"), new ListFieldBuilder("confidence", "Confidence", ["", "experimental", "probable", "potential", "by_similarity"], ["Any", "Experimental", "Probable", "Potential", "By similarity"])]), new MultiFieldBuilder("annotation.positional", "Sequence annotation [FT]", [new MapFieldBuilder("type", "Topic", FTDropDownOptions), new TextFieldBuilder("content", "Term", 21), new RangeFieldBuilder("length", "Length"), new ListFieldBuilder("confidence", "Confidence", ["", "experimental", "probable", "potential", "by_similarity"], ["Any", "Experimental", "Probable", "Potential", "By similarity"])]), Object.extend(new TextFieldBuilder("interactor", "Interacts with"), {
        build: function() {
            var A = this.inputElem.value.trim();
            if (A.toLowerCase == "self") {
                A = "self"
            } else {
                if (A.toLowerCase == "xeno") {
                    A = "xeno"
                } else {
                    if (A.match(/EBI-[0-9]+/i)) {
                        A = A.toUpperCase()
                    } else {
                        if (A.match(/(?:[A-NR-Z][0-9][A-Z]|[OPQ][0-9][A-Z0-9])[A-Z0-9]{2}[0-9](?:-[0-9+])?/i)) {
                            A = A.toUpperCase()
                        } else {
                            A = "(" + A + ")"
                        }
                    }
                }
            }
            return this.prefix(A)
        }
    }), "", new AutoCompleteFieldBuilder("keyword", "Keyword [KW]", "keywords", "name"), new MultiFieldBuilder("annotation", "Subcellular Location", [Object.extend(new TextFieldBuilder("content", "Term"), {
        build: function() {
            var A = this.inputElem.value;
            return 'type:location "' + A + '"'
        }
    }), new ListFieldBuilder("confidence", "Confidence", ["", "experimental", "probable", "potential", "by_similarity"], ["Any", "Experimental", "Probable", "Potential", "By similarity"])]), new AutoCompleteFieldBuilder("go", "Gene Ontology (GO)", "go"), new AutoCompleteFieldBuilder("ec", "Enzyme classification (EC)", "enzymes"), new ListFieldBuilder("existence", "Protein existence [PE]", ["evidence at protein level", "evidence at transcript level", "inferred from homology", "predicted", "uncertain"], ["Evidence at protein level", "Evidence at transcript level", "Inferred from homology", "Predicted", "Uncertain"]), "", new MultiFieldBuilder("citation", "Literature citation [R]", [new TextFieldBuilder("content", "Title & Abstract", 21), new TextFieldBuilder("author", "Author", 21), new TextFieldBuilder("journal", "Journal", 21), new TextFieldBuilder("published", "Year", 4)]), new IndexSelectFieldBuilder("sequencefrom", "Sequence from... [RC]", new ListFieldBuilder("content", "Type", ["tissue", "strain", "plasmid", "transposon"], ["Tissue", "Strain", "Plasmid", "Transposon"])), new TextFieldBuilder("scope", "Cited for... [RP]"), "", new MultiFieldBuilder("database", "Cross-reference", [new MapFieldBuilder("type", "Database", DrLinesDropDownChoices), new TextFieldBuilder("content", "Identifier")]), new TextFieldBuilder("web", "Web resource"), "", new RangeFieldBuilder("length", "Sequence length"), BooleanFieldBuilder("fragment", "Fragment (yes/no)"), BooleanFieldBuilder("precursor", "Precursor (yes/no)"), "", new TextFieldBuilder("mnemonic", "Entry name [ID]", 21), new TextFieldBuilder("accession", "Accession [AC]", 10), "", new DateRangeFieldBuilder("created", "Date entry integrated"), new DateRangeFieldBuilder("modified", "Date entry modified"), new DateRangeFieldBuilder("sequence_modified", "Date sequence modified"), "", BooleanFieldBuilder("reviewed", "Reviewed (yes/no)"), BooleanFieldBuilder("active", "Active (yes/no)"), "", new SubQueryTextFieldBuilder("cluster", "UniRef ID", 21), new SubQueryTextFieldBuilder("sequence", "UniParc ID", 21)],
    uniref: [new TextFieldBuilder("content", "All"), "", new TextFieldBuilder("name", "Cluster name"), new AutoCompleteFieldBuilder("taxonomy", "Taxonomy", "taxonomy"), new ListFieldBuilder("identity", "Sequence identity", ["1.0", "0.9", "0.5"], ["100%", "90%", "50%"]), new RangeFieldBuilder("count", "Cluster size"), new RangeFieldBuilder("length", "Sequence length"), new DateRangeFieldBuilder("published", "Date published"), "", new TextFieldBuilder("id", "UniRef ID", 21), new TextFieldBuilder("member", "UniProtKB ID/AC", 21), new TextFieldBuilder("member", "UniParc ID", 21)],
    uniparc: [new TextFieldBuilder("content", "All"), "", new ListFieldBuilder("database", "Database", ["embl-cds", "emblwgs", "embl_anncon", "embl_tpa", "ensembl", "epo", "flybase", "h_inv", "ipi", "jpo", "pdb", "pir", "pirarc", "prf", "refseq", "remtrembl", "sgd", "tair_arabidopsis", "tremblnew", "trome", "unimes", "uniprot", "isoforms", "uspto", "vega", "wormbase"], ["EMBL CDS", "EMBL Whole genome Shotgun (WGS)", "EMBL Annotated CONs", "EMBL Third Party Annotation (TPA)", "Ensembl", "European Patent Office (EPO)", "FlyBase", "H-Invitational Database (H-InvDB)", "International Protein Index (IPI)", "Japan Patent Office (JPO)", "PDB", "PIR-PSD", "PIR-PSD Archive", "Protein Research Foundation (PRF)", "RefSeq", "REM-TrEMBL", "Saccharomyces Genome Database (SGD)", "Arabidopsis Information Resource (TAIR)", "TrEMBLnew", "TROME", "UniProt Metagenomic and Environmental Sequences (UniMES)", "UniProt Knowledgebase (UniProtKB)", "UniProtKB Protein Isoforms", "US Patent Office (USPTO)", "Vega", "WormBase"]), new AutoCompleteFieldBuilder("taxonomy", "Taxonomy", "taxonomy"), new TextFieldBuilder("checksum", "Checksum (CRC64/MD5)", 42), "", new TextFieldBuilder("id", "UniParc ID", 21), new TextFieldBuilder("uniprot", "UniProtKB AC", 21), new TextFieldBuilder("isoform", "UniProtKB isoform ID", 21), new SubQueryTextFieldBuilder("cluster", "UniRef ID", 21)],
    taxonomy: [new TextFieldBuilder("content", "All"), "", new TextFieldBuilder("scientific", "Scientific name"), new TextFieldBuilder("common", "Common name"), new TextFieldBuilder("mnemonic", "Mnemonic (organism code)"), "", new ListFieldBuilder("rank", "Rank", ["superkingdom", "kingdom", "subkingdom", "superphylum", "phylum", "subphylum", "superclass", "class", "subclass", "infraclass", "superorder", "order", "suborder", "infraorder", "parvorder", "superfamily", "family", "subfamily", "tribe", "subtribe", "genus", "subgenus", "species_group", "species_subgroup", "species", "subspecies", "varietas", "forma", "none"], ["Superkingdom", "Kingdom", "Subkingdom", "Superphylum", "Phylum", "Subphylum", "Superclass", "Class", "Subclass", "Infraclass", "Superorder", "Order", "Suborder", "Infraorder", "Parvorder", "Superfamily", "Family", "Subfamily", "Tribe", "Subtribe", "Genus", "Subgenus", "Species group", "Species subgroup", "Species", "Subspecies", "Varietas", "Forma", "None"]), new TextFieldBuilder("strain", "Strain"), new AutoCompleteFieldBuilder("host", "Virus host", "taxonomy"), BooleanFieldBuilder("complete", "Complete proteome (yes/no)"), BooleanFieldBuilder("reference", "Reference proteome (yes/no)"), BooleanFieldBuilder("linked", "External info (yes/no)"), "", new TextFieldBuilder("id", "Taxon ID", 21)],
    keywords: [new TextFieldBuilder("content", "All"), "", new AutoCompleteFieldBuilder("name", "Name", "keywords", "name"), "", new TextFieldBuilder("id", "Keyword AC", 21)],
    locations: [new TextFieldBuilder("content", "All"), "", new AutoCompleteFieldBuilder("name", "Name", "locations", "name"), "", new TextFieldBuilder("id", "Location AC", 21)],
    tissues: [new TextFieldBuilder("content", "All"), "", new TextFieldBuilder("name", "Name"), "", new TextFieldBuilder("id", "Tissue AC", 21), new TextFieldBuilder("evoc", "eVoc ID", 21)],
    citations: [new TextFieldBuilder("content", "All"), "", new TextFieldBuilder("title", "Title"), new TextFieldBuilder("author", "Author", 21), new TextFieldBuilder("journal", "Journal", 21), new TextFieldBuilder("published", "Year published", 4), "", new TextFieldBuilder("id", "PubMed ID", 21), new TextFieldBuilder("doi", "DOI")],
    journals: [new TextFieldBuilder("content", "All"), "", new TextFieldBuilder("abbreviation", "Abbreviation"), "", new TextFieldBuilder("id", "Journals AC", 21), new TextFieldBuilder("issn", "ISSN/e-ISSN", 21), new TextFieldBuilder("coden", "coden", 21)],
    database: [new TextFieldBuilder("content", "All"), "", new TextFieldBuilder("name", "Name"), new TextFieldBuilder("abbreviation", "Abbreviation"), "", new TextFieldBuilder("id", "Database AC", 21)],
    news: [new TextFieldBuilder("content", "All"), "", new DateRangeFieldBuilder("published", "Date published")],
    docs: [new TextFieldBuilder("content", "All"), "", new DateRangeFieldBuilder("published", "Date published"), "", new TextFieldBuilder("uniprot", "UniProtKB AC", 21)],
    help: [new TextFieldBuilder("content", "All"), "", new DateRangeFieldBuilder("published", "Date published"), new ListFieldBuilder("category", "Category", ["background", "services", "website"], ["Background", "Services", "Website"])],
    faq: [new TextFieldBuilder("content", "All"), "", new DateRangeFieldBuilder("published", "Date published")],
    manual: [new TextFieldBuilder("content", "All"), "", new DateRangeFieldBuilder("published", "Date published")],
    program: [new TextFieldBuilder("content", "All"), "", new DateRangeFieldBuilder("published", "Date published"), "", new TextFieldBuilder("teammember", "Program team member")]
};
UniProt.querybuilder = {
    classes: {
        FieldBuilder: FieldBuilder,
        TextFieldBuilder: TextFieldBuilder,
        MultiFieldBuilder: MultiFieldBuilder,
        DateRangeFieldBuilder: DateRangeFieldBuilder
    },
    builders: builders
};

function showBuilder() {
    var G = document.forms["search-form"].elements.dataset.value;
    var L = $("query-builder-container");
    var A = Builder.node("form", {
        action: "#",
        onsubmit: "addConstraint(); return false"
    });
    L.appendChild(A);
    var M = Builder.node("table", {
        id: "query-builder"
    });
    var J = Builder.node("tbody");
    M.appendChild(J);
    var B = Builder.node("tr");
    J.appendChild(B);
    builderNode = B;
    addOperatorSelector(B, getQueryField().value.length == 0);
    var F = Builder.node("td");
    B.appendChild(F);
    var E = Builder.node("p", {
        className: "label"
    }, "Field");
    F.appendChild(E);
    var D = document.createElement("p");
    F.appendChild(D);
    var C = Builder.node("select", {
        onchange: "showField('" + G + "', this.value)"
    });
    D.appendChild(C);
    var K = UniProt.querybuilder.builders[G];
    for (var H = 0; H < K.length; ++H) {
        if (K[H]) {
            var I = Builder.node("option", {
                value: K[H].id,
                label: K[H].label
            }, K[H].label);
            UniProt.help(G, I);
            C.appendChild(I)
        } else {
            C.appendChild(Builder.node("option", {
                disabled: "disabled"
            }, "--"))
        }
    }
    C.selectedIndex = 0;
    showField(G, K[0].id);
    showBuilderSubmit(B);
    Form.disable(document.forms["search-form"]);
    A.appendChild(M)
}
function addOperatorSelector(D, F) {
    var A = document.createElement("td");
    D.appendChild(A);
    var E = Builder.node("p", {
        className: "invisible-label"
    }, "...");
    A.appendChild(E);
    var C = Builder.node("p");
    A.appendChild(C);
    var B = Builder.node("select", {
        id: "query-builder-op"
    });
    C.appendChild(B);
    if (F) {
        addOption("", "", B);
        addOption("NOT", "NOT", B)
    } else {
        addOption("AND", "AND", B);
        addOption("NOT", "NOT", B);
        addOption("OR", "OR", B)
    }
    B.selectedIndex = 0
}
function addOption(G, D, F, C) {
    var B = {
        value: G
    };
    if (D.charAt(0) == "*") {
        D = D.substr(1);
        B.className = "topitem"
    } else {
        if (D.charAt(0) == " ") {
            B.className = "subitem"
        }
    }
    var H = D.ltrim();
    for (var A = 0; A < (D.length - H.length); A++) {
        H = "\xA0" + H
    }
    var E = Builder.node("option", B, H);
    UniProt.help("none", E);
    F.appendChild(E)
}
function showBuilderSubmit(D) {
    var A = Builder.node("td");
    D.appendChild(A);
    submitNode = A;
    A.appendChild(Builder.node("p", {
        className: "invisible-label"
    }, "..."));
    var C = Builder.node("p", {
        style: "white-space: nowrap"
    });
    A.appendChild(C);
    C.appendChild(Builder.node("input", {
        type: "submit",
        value: "Add & Search"
    }));
    C.appendChild(document.createTextNode(" "));
    C.appendChild(Builder.node("input", {
        type: "button",
        value: "Cancel",
        onclick: "closeConstraint()"
    }));
    var B = Builder.node("td", {
        className: "full-width"
    });
    D.appendChild(B)
}
function showField(E, D) {
    while (builderNodes.length > 0) {
        var C = builderNodes.pop();
        if (C.remove) {
            C.remove()
        } else {
            C.parentNode.removeChild(C)
        }
    }
    var F = builders[E];
    for (var B = 0;
    B < F.length; ++B) {
        if (F[B].id == D) {
            F[B].render(builderNode);
            var A = "";
            if (builder && builder.deactivate) {
                A = builder.deactivate()
            }
            builder = F[B];
            if (builder.activate) {
                builder.activate(A)
            }
            break
        }
    }
}
function addConstraint() {
    var B = builder.build();
    if (B) {
        var A = getQueryField();
        var C = $("query-builder-op");
        if (C.value) {
            if (isPrecedenceAffected(A.value, C.value)) {
                A.value = "(" + A.value + ")"
            }
            A.value += " " + C.value + " "
        }
        A.value += B;
        closeConstraint();
        document.forms["search-form"].submit()
    }
}
function isPrecedenceAffected(B, A) {
    return A == "AND" && B.match(/ OR /i) || A == "NOT" && B.match(/ OR /i) || A == "OR" && B.match(/ (AND|NOT) /i)
}
function closeConstraint(B) {
    builderNodes.clear();
    builderNode = null;
    submitNode = null;
    builder = null;
    $("query-builder").remove();
    $("query-builder-link").show();
    Form.enable(document.forms["search-form"]);
    var A = getQueryField();
    A.focus()
}
function getQueryField() {
    return document.forms["search-form"].elements.query
}
function filter(B) {
    var A = getQueryField();
    if (A.value) {
        A.value += " AND "
    }
    A.value += B;
    document.forms["search-form"].submit()
}
function updateFrom() {
    if (isUniProtKB("map-to") == false) {
        document.getElementById("map-from").options[0].selected = true
    }
}
function updateTo() {
    if (isUniProtKB("map-from") == false) {
        document.getElementById("map-to").options[0].selected = true
    }
}
function isUniProtKB(A) {
    if (document.getElementById(A).options[document.getElementById(A).selectedIndex].value == "ACC+ID" || document.getElementById(A).options[document.getElementById(A).selectedIndex].value == "ACC" || document.getElementById(A).options[document.getElementById(A).selectedIndex].value == "ID") {
        return true
    }
    return false
}
function swapSelection(C, A) {
    var D = $(C).selectedIndex;
    var B = $(A).selectedIndex;
    if (D > 0) {
        D += 1
    }
    if (B > 1) {
        B -= 1
    }
    $(C).selectedIndex = B;
    $(A).selectedIndex = D
}
function focusSearch(A) {
    showOne("searchbar", A, $("searchbar"), "div")
}
function focusQuery(A) {
    document.forms[A].elements.query.focus()
}
function showOne(B, E, C) {
    var D = document.getElementsByClassName(B, C);
    for (var A = 0; A < D.length; ++A) {
        UniProt.visibility.setVisible(D[A], D[A].id == E)
    }
}
var listColumns = function listColumns(D) {
    var B = $(D);
    var C;
    if (B) {
        C = "id";
        for (var A = 0; A < B.options.length; A = A + 1) {
            C += "," + B.options[A].value
        }
    }
    return C
};
var swap = function swap(B, A) {
    B.parentNode.insertBefore(B, A)
};
var hideAllComplexOptions = function hideAllComplexOptions() {
    var B = document.getElementById("complexConfiguration");
    for (var A = 0; A < B.length; A = A + 1) {
        B[A].hide()
    }
};
var copyNonComplexToList = function copyNonComplexToList(G, F) {
    var E = $(G);
    var C = $(F);
    for (var A = 0; A < E.options.length; A = A + 1) {
        var D = E.options[A];
        if (D.selected && D.value !== "id" && D.value.indexOf("(", 0) === -1) {
            var B = new Option(D.text, D.value);
            C.options[C.length] = B;
            E.options[A] = null;
            A = A - 1;
            C.selectedIndex = C.options.length - 1
        } else {
            if (D.selected && D.value !== "id") {
                E.options[A] = null;
                A = A - 1
            }
        }
        hideAllComplexOptions();
        C.focus()
    }
};
var toggleBetweenAllAndComplex = function toggleBetweenAllAndComplex(A) {
    $("hiddenColumns").toggle();
    $(A + "Options").toggle()
};

function addComplexColumns(D) {
    var A = [];
    $("complexConfiguration").childElements().each(function(F) {
        if (F.visible()) {
            var G = F.readAttribute("id").split("Options")[0];
            var E = F.childElements();
            E.each(function(H) {
                if (H.checked) {
                    A.push(G + "(" + H.value + ")")
                }
            })
        }
    });
    if (A.length > 0) {
        var B = [];
        var C = $(D);
        A.each(function(F) {
            var H = false;
            for (var E = 0;
            E < C.options.length; E = E + 1) {
                if (C.options[E].value === F) {
                    H = true;
                    break
                }
            }
            if (!H) {
                var G = new Option(F, F);
                C.options[C.length] = G;
                C.selectedIndex = C.options.length - 1
            }
        })
    }
    checkComplex()
}
var moveToList = function moveToList(H, G) {
    var F = $(H);
    var C = $(G);
    var D = false;
    for (var A = 0; A < F.options.length; A = A + 1) {
        var E = F.options[A];
        var B = new Option(E.text, E.value);
        if (E.selected && E.value !== "id" && E.className !== "complex") {
            C.options[C.length] = B;
            F.options[A] = null;
            A = A - 1;
            C.selectedIndex = C.options.length - 1
        }
        if (E.selected && E.value !== "id" && E.className === "complex") {
            if (!D) {
                $("customize-show").toggle();
                $("complex_Add").toggle();
                $("customize-cancel").toggle();
                $("customize-cancel-complex").toggle();
                D = true
            }
            markAlreadyPresent(C, E.value);
            toggleBetweenAllAndComplex(E.value)
        }
        C.focus(E)
    }
};

function markAlreadyPresent(B, A) {
    $(A + "Options").childElements().each(function(E) {
        if (E.readAttribute("type") != null) {
            var F = E.readAttribute("value");
            var C = false;
            for (var D = 0; D < B.length; D++) {
                var G = (new RegExp(/(.+)\((.+)\)/g)).exec(B[D].value);
                if (G && G[2] === F) {
                    C = true;
                    break
                }
            }
            E.checked = C
        }
    })
}
function moveUp(E) {
    var C = $(E);
    for (var A = 1;
    A < C.options.length; A = A + 1) {
        var D = C.options[A];
        var B = C.options[A - 1];
        if (D.selected && !B.selected) {
            swap(D, B)
        }
    }
}
function moveDown(E) {
    var C = $(E);
    for (var A = C.options.length - 2; A >= 0; A = A - 1) {
        var D = C.options[A];
        var B = C.options[A + 1];
        if (D.selected && !B.selected) {
            swap(B, D)
        }
    }
}
function getSelectedOption(B) {
    var A = $(B);
    if (A) {
        return A.options[A.selectedIndex].value
    }
}
function saveConfiguration(C) {
    var B = listColumns("visibleColumns");
    if (B) {
        save(C + "-columns", B, C.split("-")[0])
    }
    var A = getSelectedOption("set-limit");
    if (A) {
        save("limit", A)
    }
}
function resetConfiguration(A) {
    deleteCookie(A + "-columns", A.split("-")[0]);
    deleteCookie("limit")
}
function checkComplex() {
    if (!($("customize-show").visible())) {
        $("customize-show").toggle();
        var A = [];
        $("complexConfiguration").childElements().each(function(B) {
            if (B.visible()) {
                toggleBetweenAllAndComplex(B.readAttribute("id").split("Options")[0])
            }
        });
        $("complex_Add").toggle()
    }
}
function formatInterval(E) {
    var F = "";
    var H = Math.floor(E / 1000 % 60);
    var D = Math.floor(E / (1000 * 60) % 60);
    var C = Math.floor(E / (1000 * 60 * 60));
    if (H + D + C > 0) {
        var B = 0;
        var A = 0;
        var G = "";
        if (C > 0) {
            B = C;
            A = D;
            G = "h"
        } else {
            if (D > 0) {
                B = D;
                A = H;
                G = "min"
            } else {
                if (H > 0) {
                    B = H;
                    G = "s"
                }
            }
        }
        if (B > 0) {
            F += B
        }
        if (A > 0) {
            F += ":";
            if (A < 10) {
                F += "0"
            }
            F += A
        }
        F = " for " + F + G
    }
    return F
}
UniProt.TOC = {};
UniProt.TOC.height = 0;
UniProt.TOC.register = function register() {
    UniProt.TOC.determineHeight();
    $$("a").each(function(B) {
        var A = B.readAttribute("href");
        if (A) {
            if (A.match("#") && (!A.match("/"))) {
                Event.on(B, "click", UniProt.TOC.movePageUp)
            }
        }
    })
};
UniProt.TOC.determineHeight = function() {
    $$("div.toc").each(function(A) {
        if (UniProt.TOC.height < A.getHeight()) {
            UniProt.TOC.height = A.getHeight()
        }
    })
};
UniProt.TOC.movePageUp = function movePageUp(B, A) {
    var C = this.readAttribute("href").split("#");
    if ($(C[1])) {
        B.preventDefault();
        UniProt.TOC.realMovePageUp(C[1])
    }
};
UniProt.TOC.realMovePageUp = function realMovePageUp(C) {
    if ($(C)) {
        var B = document.viewport.getScrollOffsets()[0];
        var A = $(C).cumulativeOffset();
        window.location.hash = C;
        window.scrollTo(B, A[1] - (UniProt.TOC.height))
    }
};

function setToggleText(A, B) {
    A.innerHTML = B ? "Hide" : "Show"
}
UniProt.ensureCookie = function(B) {
    var A = load(B + "-longColumns");
    if (A === null) {
        saveConfiguration(B)
    }
};
UniProt.hideShortShowLong = function(F, E) {
    var D = $$("." + F);
    for (var C = 0; C < D.length; C += 1) {
        D[C].select("div.short")[0].hide();
        D[C].select("div.long")[0].show()
    }
    $$("span#" + F + "Header img.long")[0].show();
    $$("span#" + F + "Header img.short")[0].hide();
    UniProt.ensureCookie(E);
    var B = load(E + "-longColumns");
    var H = F.replace("_", " ");
    if (B !== null) {
        B = B.split(",");
        var G = false;
        for (var A = 0; A < B.length; A = A + 1) {
            if (B[A] === H) {
                G = true
            }
        }
        if (!G) {
            B[B.length] = H;
            save(E + "-longColumns", B, E.split("-")[0])
        }
    } else {
        B = new Array(1);
        B[0] = H;
        save(E + "-longColumns", B, E.split("-")[0])
    }
};
UniProt.hideLongShowShort = function(F, E) {
    var D = $$("." + F);
    for (var C = 0; C < D.length;
    C += 1) {
        D[C].select(".short")[0].show();
        D[C].select(".long")[0].hide()
    }
    $$("span#" + F + "Header img.long")[0].hide();
    $$("span#" + F + "Header img.short")[0].show();
    UniProt.ensureCookie(E);
    var B = load(E + "-longColumns");
    if (B !== null) {
        B = B.split(",");
        var G = F.replace("_", " ");
        for (var A = 0; A < B.length; A = A + 1) {
            if (B[A] === G) {
                B = B.without(G)
            }
        }
        save(E + "-longColumns", B, E.split("-")[0])
    }
};

function toggleClasses(D, F) {
    var E = document.getElementsByClassName(D);
    for (var C = 0; E.length > C; ++C) {
        E[C].show()
    }
    var B = document.getElementsByClassName(F);
    for (var A = 0; B.length > A; ++A) {
        B[A].hide()
    }
}
UniProt.blast = {};
UniProt.blast.unColorSimilarity = function() {
    $$("span.similar").each(function(A) {
        A.setStyle({
            backgroundColor: "white",
            borderBottom: "none",
            borderTop: "none"
        })
    });
    $$("span.identical").each(function(A) {
        A.setStyle({
            backgroundColor: "white",
            borderBottom: "none",
            borderTop: "none"
        })
    });
    $$("span.lesssimilar").each(function(A) {
        A.setStyle({
            backgroundColor: "white",
            borderBottom: "none",
            borderTop: "none"
        })
    });
    $$("span.gap").each(function(A) {
        A.setStyle({
            backgroundColor: "white",
            borderBottom: "none",
            borderTop: "none"
        })
    })
};
var ideC = "#cccccc";
var simC = "#e5e4e2";
var lsimC = "#efefef";
var gapC = "#EEEEEE";
UniProt.blast.colorSimilarity = function(B) {
    if (B === null || B === undefined) {
        B = 1
    }
    var C = B + "em solid ";
    var A = B + "em solid ";
    if (B > 1) {
        var A = "none"
    }
    $$("span.similar").each(function(D) {
        D.setStyle({
            backgroundColor: simC,
            borderBottom: A + simC,
            borderTop: C + simC
        })
    });
    $$("span.identical").each(function(D) {
        D.setStyle({
            backgroundColor: ideC,
            borderBottom: A + ideC,
            borderTop: C + ideC
        })
    });
    $$("span.lesssimilar").each(function(D) {
        D.setStyle({
            backgroundColor: lsimC,
            borderTop: C + lsimC
        })
    });
    $$("span.gap").each(function(D) {
        D.setStyle({
            backgroundColor: gapC,
            borderTop: C + gapC
        })
    })
};
UniProt.blast.submitBlastForm = function() {
    var B = $("blastQuery").value.ltrim();
    if (UniProt.align.validateFasta.needValidation(B)) {
        var A = UniProt.align.validateFasta.validation(B, {
            id: "fastaBlastError",
            qId: "blastQuery"
        });
        switch (A) {
        case -1:
            break;
        default:
            document.forms["blast-form"].submit()
        }
    } else {
        var C = $("fastaBlastError");
        if (C && C.visible()) {
            C.toggle()
        }
        document.forms["blast-form"].submit()
    }
};
UniProt.align = {};
UniProt.align.newAlignment = function() {
    originalQuery = $("alignQuery").getValue();
    additionalQuery = $("additionalSequences").value;
    newAlignment = originalQuery + "\r\n" + additionalQuery;
    $("alignQuery").value = newAlignment;
    document.forms["align-form"].submit()
};

function showAlignOptions() {
    $("align-options-show").hide();
    $("align-options-hide").show();
    $("align-options").show();
    save("align-options", "show")
}
function hideAlignOptions() {
    $("align-options-hide").hide();
    $("align-options-show").show();
    $("align-options").hide();
    deleteCookie("align-options")
}
function submitAlignForm(A) {
    if (A) {
        $("alignQuery").update(A)
    }
    var C = $("alignQuery").value.ltrim();
    if (UniProt.align.validateFasta.needValidation(C)) {
        var B = UniProt.align.validateFasta.validation(C, {
            id: "fastaAlignError",
            qId: "alignQuery"
        });
        switch (B) {
        case -1:
            break;
        default:
            document.forms["align-form"].submit()
        }
    } else {
        var D = $("fastaAlignError");
        if (D && D.visible()) {
            D.toggle()
        }
        document.forms["align-form"].submit()
    }
}
UniProt.align.validateFasta = {
    validation: function validate(F, D) {
        var E = F.split("\n");
        var C = 0;
        var B = 0;
        var A = "";
        D.errorMessage = "Error in FASTA format at line ";
        for (; B < E.length;
        B++) {
            switch (C) {
            case 0:
                if (E[B].charAt(0) !== ">") {
                    C = -1
                } else {
                    C = 1
                }
                break;
            case 1:
                if (E[B].indexOf(">") !== -1) {
                    C = -1
                } else {
                    if (E[B].indexOf("-") !== -1) {
                        C = -1;
                        D.errorMessage = "Cannot have - character as in line "
                    } else {
                        C = 2
                    }
                }
                break;
            case 2:
                if (E[B].charAt(0) === ">") {
                    C = 1
                } else {
                    if (E[B].indexOf(">") !== -1) {
                        C = -1
                    } else {
                        if (E[B].indexOf("-") !== -1) {
                            D.errorMessage = "Cannot have - character as in line ";
                            C = -1
                        } else {
                            C = 2
                        }
                    }
                }
                break;
            case -1:
                B = E.length;
                break
            }
            if (C == -1) {
                break
            }
        }
        if (C == -1) {
            this.reportError(E, B, D)
        }
        return C
    },
    needValidation: function(A) {
        return A.charAt(0) === ">"
    },
    reportError: function printError(H, D, F) {
        var A = $(F.id);
        if (A.visible()) {
            A.toggle()
        }
        A.update("");
        var C = UniProt.htmlUtils.addElement(A, "pre");
        var I = D + 1;
        var G = $(F.qId).getDimensions();
        UniProt.htmlUtils.addLabel(C, {
            "class": "errorlabel"
        }, F.errorMessage + I);
        var B = UniProt.htmlUtils.addDiv(C, {
            style: "width:" + G.width + "px;height:" + G.height + "px;overflow:auto"
        });
        var E = UniProt.htmlUtils.addElement(B, "ol", {
            "class": "fastaError"
        });
        H.each(function(M, L) {
            var R = "";
            for (var N = 0; N < M.length; N++) {
                if (N != 0 && N % 60 == 0) {
                    R = R + "\n"
                } else {
                    R = R + M.charAt(N)
                }
            }
            var O = L + 1;
            var Q = "codeLine";
            var K = "";
            if (L === D) {
                Q = Q + " errorLine";
                K = "errorContent"
            } else {
                K = "codeContent"
            }
            var P = UniProt.htmlUtils.addElement(E, "li", {
                "class": Q
            });
            var J = UniProt.htmlUtils.addElement(P, "code", {
                "class": K
            }, R)
        });
        A.toggle()
    }
};
UniProt.align.programOptions = "";
UniProt.align.testOption = function() {
    var A = document.getElementById("align_program");
    A.options[A.options.length] = new Option("clustalo_mock", "clustalo_mock");
    A.selectedIndex = A.options.length - 1
};
UniProt.align.loadProgramOptions = function() {
    if (UniProt.align.programOptions === "") {
        new Ajax.Request(BASE + "align/options/", {
            method: "get",
            requestHeaders: {
                Accept: "application/json"
            },
            onSuccess: function(B) {
                var A = B.responseText;
                if (A != null) {
                    UniProt.align.programOptions = A.evalJSON(true);
                    UniProt.align.populateProgramDropDown(UniProt.align.programOptions)
                }
            },
            onFailure: function() {}
        })
    } else {
        UniProt.align.populateProgramDropDown(UniProt.align.programOptions)
    }
};
UniProt.align.populateProgramDropDown = function(A) {
    if (A) {
        var B = $("align_program");
        A.Id.each(function(D) {
            var C = document.createElement("option");
            C.txt = D;
            C.value = D;
            C.label = D;
            C.text = D;
            B.options.add(C)
        })
    }
};
UniProt.align.guideTree = {
    dataAttribute: "class",
    dataTypes: ["Tax"],
    selectDivs: function(B) {
        var A = $$("div." + B);
        if (A && A.length > 0) {
            return A
        } else {
            return null
        }
    },
    iterate: function(C, B, D) {
        for (var A = 0;
        A < B.length; A++) {
            C(B[A], D)
        }
    },
    color: function(A) {
        var B = this.selectDivs(A);
        if (B != null) {
            this.iterate(function(D, F) {
                var E = D.readAttribute("class");
                var C = (new RegExp(F)).exec(E)[2];
                D.style.borderColor = C
            }, B, A + " (\\{border-color : (.*)\\})", "gi");
            this.addToolTip(A)
        }
    },
    removeColor: function(A) {
        var B = this.selectDivs(A);
        this.iterate(function(C) {
            C.style.borderColor = "#000000"
        }, B, null);
        this.clearToolTip(A)
    },
    addToolTip: function(B) {
        var A = $$("span.data_" + B);
        if (A != null) {
            this.iterate(function(E, G) {
                var F = E.innerHTML;
                var D = E.parentNode.getElementsByTagName("a")[0];
                var C = Element.extend(D);
                C.observe("mouseover", function(H) {
                    new tooltip().show(H, F)
                })
            }, A, null)
        }
    },
    clearToolTip: function(B) {
        var A = $$("span.data_" + B);
        if (A != null) {
            this.iterate(function(D, F) {
                var E = D.innerHTML;
                var C = D.parentNode.getElementsByTagName("a")[0];
                C.setAttribute("onmouseover", "")
            }, A, null)
        }
    },
    reinitColoringOnPageReload: function(A) {
        if ($$("input#Taxonomy").checked) {
            UniProt.align.guideTree.color("Tax");
            UniProt.align.guideTree.addToolTip("Tax")
        }
    }
};
UniProt.colheaders = {};
UniProt.colheaders.load = function(C, B) {
    var D = "";
    var A = C.split("+");
    A.each(function(F, E) {
        if (E === A.length - 1) {
            D = D + "category:" + F
        } else {
            D = D + "category:" + F + "%20AND%20"
        }
    });
    D = BASE + "colheaders/?format=json&query=" + D;
    UniProt.utilities.MakeAjaxCall(D, function(E) {
        UniProt.colheaders.populateColHeaders(E, B)
    })
};
UniProt.colheaders.populateColHeaders = function(D, B) {
    var C = $(B);
    C.update("");
    UniProt.htmlUtils.addh2(C).update(D.header);
    var A = UniProt.htmlUtils.addTable(C, {
        "class": "grid"
    });
    D.table.each(function(F, E) {
        var G = UniProt.htmlUtils.addtr(A);
        if (E === 0) {
            UniProt.htmlUtils.addth(G).update(F.name);
            UniProt.htmlUtils.addth(G).update(F.value)
        } else {
            UniProt.htmlUtils.addtd(G).update(F.name);
            UniProt.htmlUtils.addtd(G).update(F.value)
        }
    });
    if (!C.visible()) {
        C.toggle()
    }
    C.scrollTo()
};

function LoadJavaScript() {
    var index = 0;
    for (; index < chainedFunctions.length; index = index + 1) {
        eval(chainedFunctions[index])
    }
    chainedFunctions.clear();
    var body = document.getElementsByTagName("body")[0];
    body.setAttribute("onkeydown", "keyDown(event)");
    body.setAttribute("onkeyup", "keyUp(event)")
}
LoadJavaScript();
