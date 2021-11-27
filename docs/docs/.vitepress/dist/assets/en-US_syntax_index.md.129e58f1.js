import{o as n,c as a,a as s}from"./app.c9011ed2.js";const t='{"title":"Syntax of Hetu Script Language","description":"","frontmatter":{},"headers":[{"level":2,"title":"Comments","slug":"comments"},{"level":2,"title":"Variable","slug":"variable"},{"level":2,"title":"Type declaration","slug":"type-declaration"},{"level":2,"title":"Function","slug":"function"},{"level":2,"title":"Class","slug":"class"},{"level":2,"title":"Control flow","slug":"control-flow"},{"level":3,"title":"If","slug":"if"},{"level":3,"title":"While","slug":"while"},{"level":3,"title":"Do","slug":"do"},{"level":3,"title":"For","slug":"for"},{"level":3,"title":"When","slug":"when"},{"level":2,"title":"Keywords","slug":"keywords"},{"level":2,"title":"Operators","slug":"operators"}],"relativePath":"en-US/syntax/index.md","lastUpdated":1628588881003}',e={},o=s('<h1 id="syntax-of-hetu-script-language"><a class="header-anchor" href="#syntax-of-hetu-script-language" aria-hidden="true">#</a> Syntax of Hetu Script Language</h1><p>Hetu&#39;s grammar is close to most modern languages, it need very little time to get familar with.</p><p>Key characteristics of Hetu:</p><ul><li><p>Declarations starts with a keyword before the identifier: var, final, fun, construct, get, set, class, type, etc.</p></li><li><p>Semicolon is optional. In most cases, the interpreter will know when a statement is finished. In rare cases, the lexer will implicitly add &quot;end of statement token&quot; (a semicolon in default lexicon) to avoid ambiguities. For example, before a line when the line starts with one of &#39;++, --, (, [, {&#39;, or after a line when the line ends with &#39;return&#39;.</p></li><li><p>Type annotation is optional. Type is annotated <strong>with a colon after the identifier</strong> like typescript/kotlin/swift.</p></li><li><p>Use [when] instead of [switch]</p></li></ul><h2 id="comments"><a class="header-anchor" href="#comments" aria-hidden="true">#</a> Comments</h2><div class="language-typescript"><pre><code><span class="token comment">// This is a comment.</span>\n<span class="token comment">/* These are multi-line comments:\nanother line.*/</span>\n</code></pre></div><h2 id="variable"><a class="header-anchor" href="#variable" aria-hidden="true">#</a> Variable</h2><p>Variable is declared with [var], [final]. The type annotation and initialize expression is optional.</p><div class="language-typescript"><pre><code><span class="token keyword">var</span> person<span class="token punctuation">;</span>\n<span class="token keyword">var</span> fineStructureConstant<span class="token operator">:</span> num <span class="token operator">=</span> <span class="token number">1</span> <span class="token operator">/</span> <span class="token number">137</span><span class="token punctuation">;</span>\n<span class="token keyword">var</span> isTimeTravelSuccessful<span class="token operator">:</span> bool <span class="token operator">=</span> <span class="token boolean">true</span><span class="token punctuation">;</span>\n<span class="token keyword">var</span> skill<span class="token operator">:</span> Map<span class="token operator">&lt;</span>str<span class="token operator">&gt;</span> <span class="token operator">=</span> <span class="token punctuation">{</span>\n  tags<span class="token operator">:</span> <span class="token punctuation">[</span><span class="token string">&#39;attack&#39;</span><span class="token punctuation">]</span><span class="token punctuation">,</span>\n  script<span class="token operator">:</span> <span class="token string">&#39;//path/to/skill_script.ht&#39;</span><span class="token punctuation">,</span>\n<span class="token punctuation">}</span><span class="token punctuation">;</span>\n</code></pre></div><p>Variables will be given a type if it has an initialize expression. And you cannot re-assign it with another type. However, if you declare a variable with no initialize expression, the variable will be considered as having a [any] type (equals to dart&#39;s dynamic type).</p><div class="language-typescript"><pre><code><span class="token keyword">var</span> name <span class="token operator">=</span> <span class="token string">&#39;naruto&#39;</span><span class="token punctuation">;</span>\n<span class="token comment">// name = 2020 // error!</span>\n</code></pre></div><p>String literal can have interpolation the same to Javascript:</p><div class="language-dart"><pre><code><span class="token keyword">var</span> a <span class="token operator">=</span> <span class="token string">&#39;dragon&#39;</span>\n<span class="token comment">// print: To kill the dragon, you have to wait 42 years.</span>\n<span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&#39;To kill the ${a}, you have to wait ${6*7} years.&#39;</span><span class="token punctuation">)</span>\n</code></pre></div><p>A little difference from Dart is that you have to write a curly brackets even if you have only one identifier.</p><h2 id="type-declaration"><a class="header-anchor" href="#type-declaration" aria-hidden="true">#</a> Type declaration</h2><p>Type is a variable in Hetu, it can be assigned and returned. The type of a type is always &#39;type&#39;, no matter it&#39;s a primitive, instance, or function type. Use &#39;runtimeType&#39; to get the runtime type of a value.</p><div class="language-typescript"><pre><code>fun main <span class="token punctuation">{</span>\n  <span class="token comment">// decalre a function typedef</span>\n  <span class="token keyword">var</span> funcTypedef<span class="token operator">:</span> <span class="token keyword">type</span> <span class="token operator">=</span> <span class="token function">fun</span><span class="token punctuation">(</span>str<span class="token punctuation">)</span> <span class="token operator">-</span><span class="token operator">&gt;</span> num\n  <span class="token comment">// assign a function to a value of a certain function type</span>\n  <span class="token class-name"><span class="token keyword">var</span></span> numparse<span class="token operator">:</span> funcTypedef <span class="token operator">=</span> <span class="token function">fun</span><span class="token punctuation">(</span>value<span class="token operator">:</span> str<span class="token punctuation">)</span> <span class="token operator">-</span><span class="token operator">&gt;</span> num <span class="token punctuation">{</span> <span class="token keyword">return</span> num<span class="token punctuation">.</span><span class="token function">parse</span><span class="token punctuation">(</span>value<span class="token punctuation">)</span> <span class="token punctuation">}</span>\n  <span class="token comment">// get a value&#39;s runtime type and return it from a function</span>\n  <span class="token keyword">var</span> getType <span class="token operator">=</span> fun <span class="token punctuation">{</span> <span class="token keyword">return</span> numparse<span class="token punctuation">.</span>runtimeType <span class="token punctuation">}</span>\n  <span class="token keyword">var</span> funcTypedef2 <span class="token operator">=</span> <span class="token function">getType</span><span class="token punctuation">(</span><span class="token punctuation">)</span>\n  <span class="token comment">// use this new type</span>\n  <span class="token keyword">var</span> strlength<span class="token operator">:</span> funcTypedef2 <span class="token operator">=</span> <span class="token function">fun</span><span class="token punctuation">(</span>value<span class="token operator">:</span> str<span class="token punctuation">)</span> <span class="token operator">-</span><span class="token operator">&gt;</span> num <span class="token punctuation">{</span> <span class="token keyword">return</span> value<span class="token punctuation">.</span>length <span class="token punctuation">}</span>\n  <span class="token comment">// expected output: 11</span>\n  <span class="token function">print</span><span class="token punctuation">(</span><span class="token function">strlength</span><span class="token punctuation">(</span><span class="token string">&#39;hello world&#39;</span><span class="token punctuation">)</span><span class="token punctuation">)</span>\n<span class="token punctuation">}</span>\n</code></pre></div><h2 id="function"><a class="header-anchor" href="#function" aria-hidden="true">#</a> Function</h2><p>Function is declared with [fun], [get], [set], [construct]. The parameter list, return type and function body are all optional. For functions with no parameters, the empty brackets are also optional. If this is a function expression (or literal function, or anonymous function) the function name is also optional.</p><div class="language-typescript"><pre><code>fun <span class="token function">doubleIt</span><span class="token punctuation">(</span>n<span class="token operator">:</span> num<span class="token punctuation">)</span> <span class="token operator">-</span><span class="token operator">&gt;</span> num <span class="token punctuation">{</span>\n  <span class="token keyword">return</span> n <span class="token operator">*</span> <span class="token number">2</span>\n<span class="token punctuation">}</span>\n\nfun main <span class="token punctuation">{</span>\n  def x <span class="token operator">=</span> <span class="token function">doubleIt</span><span class="token punctuation">(</span><span class="token number">7</span><span class="token punctuation">)</span> <span class="token comment">// expect 14</span>\n  <span class="token function">print</span><span class="token punctuation">(</span>x<span class="token punctuation">)</span>\n<span class="token punctuation">}</span>\n</code></pre></div><ul><li>For functions declared with [fun], when no return type is provided in declaration, it will have a return type of [any]. And it will return null if you didn&#39;t write return statement within the definition body.</li><li>Member functions can also be declared with [get], [set], [construct], they literally means getter, setter and contructor function.</li><li>If a class have a getter or setter function. You can use &#39;class_name.func_name&#39; to get or set the value hence get rid of the empty brackets.</li><li>Function can have no name, it will then become a literal function expression(anonymous function).</li><li>Functions can be nested, and nested functions can have names.</li><li>Function are first class, you can use function as parameter, return value and store them in variables.</li><li>Function must be within a block statement (within &#39;{&#39; and &#39;}&#39;).</li><li>Return type is marked by a single arrow (&#39;-&gt;&#39;) after the parameters.</li><li>If a literal function is declared without a definition body, then it is deemed as a function type rather than an function definition.</li></ul><div class="language-typescript"><pre><code>fun <span class="token function">closure</span><span class="token punctuation">(</span>func<span class="token punctuation">)</span> <span class="token punctuation">{</span>\n  <span class="token keyword">var</span> i <span class="token operator">=</span> <span class="token number">42</span>\n  fun nested <span class="token punctuation">{</span>\n    <span class="token keyword">return</span> i <span class="token operator">=</span> i <span class="token operator">+</span> <span class="token number">1</span>\n  <span class="token punctuation">}</span>\n  <span class="token keyword">return</span> nested\n<span class="token punctuation">}</span>\n\nfun main <span class="token punctuation">{</span>\n  <span class="token keyword">var</span> func <span class="token operator">=</span> <span class="token function">closure</span><span class="token punctuation">(</span> <span class="token function">fun</span> <span class="token punctuation">(</span>n<span class="token punctuation">)</span> <span class="token punctuation">{</span> <span class="token keyword">return</span> n <span class="token operator">*</span> n <span class="token punctuation">}</span> <span class="token punctuation">)</span>\n  <span class="token function">print</span><span class="token punctuation">(</span><span class="token function">func</span><span class="token punctuation">(</span><span class="token punctuation">)</span><span class="token punctuation">)</span> <span class="token comment">// print: 1849</span>\n  <span class="token function">print</span><span class="token punctuation">(</span><span class="token function">func</span><span class="token punctuation">(</span><span class="token punctuation">)</span><span class="token punctuation">)</span> <span class="token comment">// print: 1936</span>\n<span class="token punctuation">}</span>\n</code></pre></div><h2 id="class"><a class="header-anchor" href="#class" aria-hidden="true">#</a> Class</h2><ul><li>Class can have static variables and methods. Which can be accessed through the class name.</li><li>Class&#39;s member functions (methods) use special keyword: construct, get, set, to define a constructor, getter, setter function.</li><li>Constructors can be with no function name and cannot return values. When calling they will always return a instance.</li><li>Getter &amp; setter functions can be used feels like a member variable. They can be accessed without brackets.</li><li>Use &#39;extends&#39; to inherits other class&#39;s members</li></ul><div class="language-typescript"><pre><code><span class="token comment">// class definition</span>\n<span class="token keyword">class</span> <span class="token class-name">Calculator</span> <span class="token punctuation">{</span>\n  <span class="token comment">// instance member</span>\n  <span class="token keyword">var</span> x<span class="token operator">:</span> num\n  <span class="token keyword">var</span> y<span class="token operator">:</span> num\n  <span class="token comment">// static private member</span>\n  <span class="token keyword">static</span> <span class="token keyword">var</span> _name <span class="token operator">=</span> <span class="token string">&#39;the calculator&#39;</span>\n  <span class="token comment">// static get function</span>\n  <span class="token keyword">static</span> <span class="token keyword">get</span> name <span class="token operator">-</span><span class="token operator">&gt;</span> str <span class="token punctuation">{</span>\n    <span class="token keyword">return</span> _name\n  <span class="token punctuation">}</span>\n  <span class="token comment">// static set function</span>\n  <span class="token keyword">static</span> <span class="token keyword">set</span> <span class="token function">name</span><span class="token punctuation">(</span>new_name<span class="token operator">:</span> str<span class="token punctuation">)</span> <span class="token punctuation">{</span>\n    _name <span class="token operator">=</span> new_name\n  <span class="token punctuation">}</span>\n  <span class="token comment">// static function</span>\n  <span class="token keyword">static</span> fun greeting <span class="token punctuation">{</span>\n    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&#39;hello! I\\&#39;m &#39;</span> <span class="token operator">+</span> name<span class="token punctuation">)</span>\n  <span class="token punctuation">}</span>\n  <span class="token comment">// constructor with parameters</span>\n  <span class="token function">construct</span> <span class="token punctuation">(</span>x<span class="token operator">:</span> num<span class="token punctuation">,</span> y<span class="token operator">:</span> num<span class="token punctuation">)</span> <span class="token punctuation">{</span>\n    <span class="token comment">// use this to access instance members with same names</span>\n    <span class="token keyword">this</span><span class="token punctuation">.</span>x <span class="token operator">=</span> x\n    <span class="token keyword">this</span><span class="token punctuation">.</span>y <span class="token operator">=</span> y\n  <span class="token punctuation">}</span>\n  <span class="token comment">// method with return type</span>\n  <span class="token class-name">fun</span> meaning <span class="token operator">-</span><span class="token operator">&gt;</span> num <span class="token punctuation">{</span>\n    <span class="token comment">// when no shadowing, `this` keyword can be omitted</span>\n    <span class="token keyword">return</span> x <span class="token operator">*</span> y\n  <span class="token punctuation">}</span>\n<span class="token punctuation">}</span>\n</code></pre></div><h2 id="control-flow"><a class="header-anchor" href="#control-flow" aria-hidden="true">#</a> Control flow</h2><p>Hetu has while, do loops, and classic for(init;condition;increment) and for...in/of loops. As well as when statement, which works like switch.</p><div class="language-typescript"><pre><code>fun main <span class="token punctuation">{</span>\n  <span class="token keyword">var</span> i <span class="token operator">=</span> <span class="token number">0</span>\n  <span class="token keyword">for</span> <span class="token punctuation">(</span><span class="token punctuation">;</span><span class="token punctuation">;</span><span class="token punctuation">)</span> <span class="token punctuation">{</span>\n    <span class="token operator">++</span>i\n    <span class="token function">when</span> <span class="token punctuation">(</span>i <span class="token operator">%</span> <span class="token number">2</span><span class="token punctuation">)</span> <span class="token punctuation">{</span>\n      <span class="token number">0</span> <span class="token operator">-</span><span class="token operator">&gt;</span> <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&#39;even:&#39;</span><span class="token punctuation">,</span> i<span class="token punctuation">)</span>\n      <span class="token number">1</span> <span class="token operator">-</span><span class="token operator">&gt;</span> <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&#39;odd:&#39;</span><span class="token punctuation">,</span> i<span class="token punctuation">)</span>\n      <span class="token keyword">else</span> <span class="token operator">-</span><span class="token operator">&gt;</span> <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&#39;never going to happen.&#39;</span><span class="token punctuation">)</span>\n    <span class="token punctuation">}</span>\n    <span class="token keyword">if</span> <span class="token punctuation">(</span>i <span class="token operator">&gt;</span> <span class="token number">5</span><span class="token punctuation">)</span> <span class="token punctuation">{</span>\n      <span class="token keyword">break</span>\n    <span class="token punctuation">}</span>\n  <span class="token punctuation">}</span>\n<span class="token punctuation">}</span>\n</code></pre></div><h3 id="if"><a class="header-anchor" href="#if" aria-hidden="true">#</a> If</h3><ul><li>&#39;if&#39; statement&#39;s condition expression must be bool.</li><li>&#39;if&#39; statement&#39;s condition is allowed to have no brackets.</li><li>&#39;if&#39; statement&#39;s branches could be a single statement without brackets.</li><li>&#39;if&#39; can also be a expression which will have a value, in this case else branch is un-omitable.</li></ul><div class="language-dart"><pre><code><span class="token keyword">if</span> <span class="token punctuation">(</span>condition<span class="token punctuation">)</span> <span class="token punctuation">{</span>\n  <span class="token punctuation">.</span><span class="token punctuation">.</span><span class="token punctuation">.</span>\n<span class="token punctuation">}</span> <span class="token keyword">else</span> <span class="token punctuation">{</span>\n  <span class="token punctuation">.</span><span class="token punctuation">.</span><span class="token punctuation">.</span>\n<span class="token punctuation">}</span>\n</code></pre></div><h3 id="while"><a class="header-anchor" href="#while" aria-hidden="true">#</a> While</h3><div class="language-dart"><pre><code><span class="token keyword">while</span> <span class="token punctuation">(</span>condition<span class="token punctuation">)</span> <span class="token punctuation">{</span>\n  <span class="token punctuation">.</span><span class="token punctuation">.</span><span class="token punctuation">.</span>\n<span class="token punctuation">}</span>\n</code></pre></div><h3 id="do"><a class="header-anchor" href="#do" aria-hidden="true">#</a> Do</h3><ul><li>&#39;do&#39; statement&#39;s &#39;while&#39; part is optional, if omitted, it will become a anonymous namespace.</li></ul><div class="language-dart"><pre><code><span class="token keyword">do</span> <span class="token punctuation">{</span>\n  <span class="token punctuation">.</span><span class="token punctuation">.</span><span class="token punctuation">.</span>\n<span class="token punctuation">}</span> <span class="token keyword">while</span> <span class="token punctuation">(</span>condition<span class="token punctuation">)</span>\n</code></pre></div><h3 id="for"><a class="header-anchor" href="#for" aria-hidden="true">#</a> For</h3><ul><li>&#39;for&#39; statement&#39;s expr must be separated with &#39;;&#39;.</li><li>The expression itself is optional. If you write &#39;for (;😉&#39;, it will be the same to &#39;while (true)&#39;</li><li>When use for...in, the loop will iterate through the keys of a list.</li></ul><div class="language-dart"><pre><code><span class="token keyword">for</span> <span class="token punctuation">(</span> init<span class="token punctuation">;</span> condition<span class="token punctuation">;</span> increment <span class="token punctuation">)</span> <span class="token punctuation">{</span>\n  <span class="token punctuation">.</span><span class="token punctuation">.</span><span class="token punctuation">.</span>\n<span class="token punctuation">}</span>\n\n<span class="token keyword">for</span> <span class="token punctuation">(</span><span class="token keyword">var</span> item <span class="token keyword">in</span> list<span class="token punctuation">)</span> <span class="token punctuation">{</span>\n  <span class="token punctuation">.</span><span class="token punctuation">.</span><span class="token punctuation">.</span>\n<span class="token punctuation">}</span>\n</code></pre></div><h3 id="when"><a class="header-anchor" href="#when" aria-hidden="true">#</a> When</h3><ul><li>&#39;when&#39; statement&#39;s condition is optional. If not provided, the interpreter will check the cases and jump to the first branch if the expression evaled as true. In this case, the when statement is more like a if else statement except with a little more efficiency because it won&#39;t go through every branch.</li><li>&#39;when&#39; statement&#39;s case could be non-const expression or variables;</li><li>&#39;when&#39; statement&#39;s body must be enclosed in curly brackets. However, the case branch could be a single statement without brackets;</li><li>&#39;when&#39; statement&#39;s else branch is optional.</li></ul><div class="language-dart"><pre><code>when <span class="token punctuation">(</span>condition<span class="token punctuation">)</span> <span class="token punctuation">{</span>\n  expr <span class="token operator">-</span><span class="token operator">&gt;</span> expr <span class="token comment">// ...single expression...</span>\n  expr <span class="token operator">-</span><span class="token operator">&gt;</span> <span class="token punctuation">{</span>\n    <span class="token comment">// ...block statement...</span>\n  <span class="token punctuation">}</span>\n  <span class="token comment">// will not fall through here</span>\n  <span class="token keyword">else</span> <span class="token punctuation">:</span> <span class="token punctuation">{</span>\n    <span class="token comment">// ...</span>\n  <span class="token punctuation">}</span>\n<span class="token punctuation">}</span>\n</code></pre></div><h1 id="import"><a class="header-anchor" href="#import" aria-hidden="true">#</a> Import</h1><p>Use import statement to import content from another script file.</p><div class="language-dart"><pre><code><span class="token keyword">import</span> <span class="token string">&#39;hello.ht&#39;</span>\n\nfun main <span class="token punctuation">{</span>\n  <span class="token function">hello</span><span class="token punctuation">(</span><span class="token punctuation">)</span>\n<span class="token punctuation">}</span>\n</code></pre></div><h2 id="keywords"><a class="header-anchor" href="#keywords" aria-hidden="true">#</a> Keywords</h2><p>null, true, false, var, final, const, typeof, class, enum, fun, struct, interface, this, super, abstract, override, external, static, extends, implements, with, construct, factory, get, set, async, break, continue, return, for, in, of, if, else, while, do, when, is, as</p><h2 id="operators"><a class="header-anchor" href="#operators" aria-hidden="true">#</a> Operators</h2><table><thead><tr><th style="text-align:left;">Description</th><th style="text-align:left;">Operator</th><th style="text-align:center;">Associativity</th><th style="text-align:center;">Precedence</th></tr></thead><tbody><tr><td style="text-align:left;">Unary postfix</td><td style="text-align:left;">e., e1[e2], e(), e++, e--</td><td style="text-align:center;">None</td><td style="text-align:center;">16</td></tr><tr><td style="text-align:left;">Unary prefix</td><td style="text-align:left;">-e, !e, ++e, --e</td><td style="text-align:center;">None</td><td style="text-align:center;">15</td></tr><tr><td style="text-align:left;">Multiplicative</td><td style="text-align:left;">*, /, %</td><td style="text-align:center;">Left</td><td style="text-align:center;">14</td></tr><tr><td style="text-align:left;">Additive</td><td style="text-align:left;">+, -</td><td style="text-align:center;">Left</td><td style="text-align:center;">13</td></tr><tr><td style="text-align:left;">Relational</td><td style="text-align:left;">&lt;, &gt;, &lt;=, &gt;=, as, is, is!</td><td style="text-align:center;">None</td><td style="text-align:center;">8</td></tr><tr><td style="text-align:left;">Equality</td><td style="text-align:left;">==, !=</td><td style="text-align:center;">None</td><td style="text-align:center;">7</td></tr><tr><td style="text-align:left;">Logical AND</td><td style="text-align:left;">&amp;&amp;</td><td style="text-align:center;">Left</td><td style="text-align:center;">6</td></tr><tr><td style="text-align:left;">Logical Or</td><td style="text-align:left;">||</td><td style="text-align:center;">Left</td><td style="text-align:center;">5</td></tr><tr><td style="text-align:left;">Conditional</td><td style="text-align:left;">e1 ? e2 : e3</td><td style="text-align:center;">Right</td><td style="text-align:center;">3</td></tr><tr><td style="text-align:left;">Assignment</td><td style="text-align:left;">=, *=, /=, +=, -=</td><td style="text-align:center;">Right</td><td style="text-align:center;">1</td></tr></tbody></table>',49);e.render=function(s,t,e,p,c,l){return n(),a("div",null,[o])};export default e;export{t as __pageData};