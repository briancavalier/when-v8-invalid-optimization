**IMPORTANT:** The problem has been [worked around as of when.js 3.6.2](https://github.com/cujojs/when/releases). Updating to when >= 3.6.2 should avoid the failure.


This test shows what we believe is v8 generating invalid optimized code, causing a function to suddenly become undefined.  This appears to affect when.js versions 3.4.2 and higher, although the failure appears to happen under different conditions depending on the version of when.js and/or the version of v8 (via Node.js).

This particular test is design to show the failure on:

* Node 0.10.33
* when.js 3.6.0

### Run the test

```
npm install
npm test
```

### Expected result

Program completes without error.

### Actual result

Program fails at a seemingly random, but reproducible iteration.

The stack trace below points to [this line in the `_beget` function](https://github.com/cujojs/when/blob/3.6.0/lib/makePromise.js#L166).

```
<lots more output above>
#57 reading file with promise: `dist/lodash.compat.js`
#57 parsing file: `dist/lodash.compat.js`
**
 * @license
 * Lo-Dash 2.4.1 (Custom Build) <http://lodash.com/>
 * Build: `lodash -o ./dist/loda Program
registering catch # 393
Potentially unhandled rejection [1] TypeError: object is not a function
    at Promise._beget (/private/tmp/345/node_modules/when/lib/makePromise.js:166:16)
    at Promise.then (/private/tmp/345/node_modules/when/lib/makePromise.js:140:17)
    at Promise.catch (/private/tmp/345/node_modules/when/lib/makePromise.js:156:16)
    at Promise.catch.Promise.otherwise (/private/tmp/345/node_modules/when/lib/decorators/flow.js:37:22)
    at /private/tmp/345/test.js:87:24
    at next (/private/tmp/345/node_modules/when/lib/decorators/iterate.js:57:20)
    at /private/tmp/345/node_modules/when/lib/decorators/array.js:39:24
    at tryCatchReject (/private/tmp/345/node_modules/when/lib/makePromise.js:838:30)
    at runContinuation1 (/private/tmp/345/node_modules/when/lib/makePromise.js:797:4)
    at Fulfilled.when (/private/tmp/345/node_modules/when/lib/makePromise.js:588:4)
    at Pending.run (/private/tmp/345/node_modules/when/lib/makePromise.js:479:13)
#57 reading file with promise: `dist/lodash.compat.min.js`
#57 parsing file: `dist/lodash.compat.min.js`
**
 * @license
 * Lo-Dash 2.4.1 (Custom Build) lodash.com/license | Underscore.js 1.5.2 underscorejs Program
<end of output, program terminates>
```

### Potential workaround

The problem has been [worked around as of when.js 3.6.2](https://github.com/cujojs/when/releases). Updating to when >= 3.6.2 should avoid the failure.

The problem does not manifest in node 0.11.14, as far as we can tell, presumably due to it having been fixed in v8. Updating to node 0.11.14 is a potential workaround.

Note that in at least some cases (not sure about all yet), adding an empty try/finally as first line of the `_beget` function avoids the failure, presumably because that either prevents optimization, or changes the optimization in a way that avoids generating the erroneous compiled code.

```js
Promise.prototype._beget = function() {
	try {} finally {};
	...
}
```

### References

For more information see the following github issues:

* [Original issue report](https://github.com/cujojs/when/issues/345): long, best to read from bottom up or [start here](https://github.com/cujojs/when/issues/345#issuecomment-51775158)
* [Followup with test case](https://github.com/cujojs/when/issues/403) by [@anodynos](https://github.com/anodynos)
