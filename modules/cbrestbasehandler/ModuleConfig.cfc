/**
*********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component {

	// Module Properties
	this.title 				= "cbrestbasehandler";
	this.author 			= "Gavin Pickin";
	this.webURL 			= "http://www.ortussolutions.com";
	this.description 		= "Provides a Base Handler and Response Object to apply convention to your Rest Design";
	this.version			= "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "cbrestbasehandler";
	// Model Namespace
	this.modelNamespace		= "cbrestbasehandler";
	// CF Mapping
	this.cfmapping			= "cbrestbasehandler";
	// Dependencies
	this.dependencies 		= [];

	function configure(){

		// Custom Declared Points
		interceptorSettings = {};

		// Custom Declared Interceptors
		interceptors = [];

	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){

	}

}