//
//  IRWebView+DOMInjecting.js
//  Milk
//
//  Created by Evadne Wu on 2/16/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

((function () {

	window.irWebView = {
	
		"injectStyle": function (styleContents) {
		
			var styleElement = document.createElement("style");
			styleElement.setAttribute("type", "text/css");
			styleElement.appendChild(document.createTextNode(styleContents));
			(document.getElementsByTagName("head")[0]).appendChild(styleElement);
		
		},
		
		"lockViewportWidth": function () {
		
			var metaTag = document.createElement("meta");
			metaTag.setAttribute("name", "viewport");
			metaTag.setAttribute("content", "width=device-width, initial-scale=1, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no");
			(document.getElementsByTagName("head")[0]).appendChild(metaTag);			
		
		}
	
	};

})());
