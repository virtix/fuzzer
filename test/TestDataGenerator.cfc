<cfcomponent displayname="TestDataGenerator">


  <cffunction name="TestDataGenerator" returntype="TestDataGenerator">
    <cfset this.minInt = -1000000000 />
    <cfset this.maxInt =  1000000000 />
    <cfset this.stringLen =  256 />
    <cfset this.defaultRegEx = "[[:print:]]" />
    <cfreturn this />
  </cffunction>
	
	
<cffunction name="genTelephone" access="public" returntype="string" mxunit:skip="false" mxunit:tests="10">
	 <cfscript>
		var tel = ''; 
		//use the (hopefully) static genString method to generate the required sring
 		tel = '#tel##genInteger(100,999)#-#genInteger(100,999)#-#genInteger(1000,9999)#';
 		return tel;
	 </cfscript>
	</cffunction>
	
 	
	
<cffunction name="genSSN" access="public" returntype="string" mxunit:skip="false" mxunit:tests="10">
	 <cfscript>
		var ssn = ''; 
 		ssn = '#ssn##genInteger(100,999)#-#genInteger(10,99)#-#genInteger(1000,9999)#';
 		return ssn;
	 </cfscript>
	</cffunction>
	
	
<cffunction name="genCC" access="public" returntype="string" mxunit:skip="false" mxunit:tests="10">
	 <cfscript>
 		var cc = '';
 		//Might be more efficient to use genInt instead of genString when generating just integers
 		//generates nnnn nnnn nnnn nnnn [nnn-nnnn]
 		cc = '#cc##genInteger(1000,9999)# #genInteger(1000,9999)# #genInteger(1000,9999)# #genInteger(100,9999)#';
 		return cc;
	 </cfscript>
	</cffunction>
	
	
<cffunction name="genZipcode" access="public" returntype="string" mxunit:skip="false" mxunit:tests="10">
	 <cfscript>
		var zipcode = ''; 
 		//generates nnnn nnnn nnnn nnnn [nnn-nnnn]
 		zipcode = '#zipcode##genInteger(10000,99999)#';
 		return zipcode;
	 </cfscript>
	</cffunction>


<cffunction name="genInteger" access="public" returntype="numeric" mxunit:skip="false" mxunit:tests="10">
  <cfargument name="min" required="false" default="-1000000000" mxunit:type="int" mxunit:min="-1000000000" mxunit:max="1000000000"  /><!--- Min *recommended* by CF --->
  <cfargument name="max" required="false" default="1000000000"  mxunit:type="int" mxunit:min="-1000000000" mxunit:max="1000000000" /><!--- Min **recommended* by CF --->
  <cfset var theInt = 0 />
  <cfset var seed = int(rand("SHA1PRNG")* 1000000000) />
  <cfset var randomizer  = Randomize(seed, "SHA1PRNG") />
  <cfset theInt = randRange(arguments.min,arguments.max) />
  <cfreturn  theInt />
</cffunction>



<cffunction name="genFloat" access="public" returntype="numeric">
  <cfargument name="min" required="false" default="-1000000000" mxunit:type="float" mxunit:min="-1000000000.0" /><!--- Min *recommended* by CF --->
  <cfargument name="max" required="false" default="1000000000" mxunit:type="float" mxunit:min="-1000000000.0" /><!--- Min **recommended* by CF --->
  <cfset var theFloat = 0.0 />
  <cfset var theInt = 0 />
  <cfset var seed = int(rand("SHA1PRNG")* 1000000000) />
  <cfset var randomizer  = Randomize(seed, "SHA1PRNG") />
  <cfset theInt = randRange(arguments.min,arguments.max) />
  <cfset theFloat = rand("SHA1PRNG") * theInt  />
  <cfreturn  theFloat />
</cffunction>


<!--- 
Can accept simple character class regular expressions
 --->
<cffunction name="genString" access="public" returntype="string" static="true">
  <cfargument name="len" required="false" default="2048" />
  <cfargument name="regex" required="false" default="[[:print:]]" />
<!--- To Do: Check the regex itself for simple character class --->
  <cfset var i = 1 /><!--- Need to localize this as i is used in loop before for testing! --->
  <cfset var theString = '' />
  <cfset var unicodeChar = 0 />
  <cfset var seed = int(rand("SHA1PRNG")* 1000000000) />
  <cfset var randomizer  = Randomize(seed, "SHA1PRNG") />
  <cfset var gate = 1 />
  <cfset var theChar = '' />
  <cfscript>
    //Test: Should return only alpha charcaters based upon regex
    //regex = "[a-zA-Z]"; //if the character is NOT in this set i back -1
    
    for (i=1; i lte arguments.len; i = i + 1){
      unicodeChar = randRange(32,126) ;
      theChar = chr(unicodeChar);
      if(not refind(arguments.regex,theChar)){
       i = i - 1; //should cause infinite loop
      }
      else {
       theString = theString & theChar;
      }
      gate = gate + 1;
      //being safe
      if(gate gte 100000){
       theString = 'ERROR: too many loops. Could be weird regex';
      }
    }
  </cfscript>


  <cfreturn  theString />
</cffunction>



<cffunction name="genBoolean" access="public" returntype="boolean" static="true">
  
  <cfset var theBool = '' />
 
  <cfset var seed = int(rand("SHA1PRNG")* 1000000000) />
  <cfset var randomizer  = Randomize(seed, "SHA1PRNG") />
 
  <cfscript>
       theBool = iif(randrange(-123456,123456) gt 0, de("true"), de("false") );
  </cfscript>


  <cfreturn  theBool />
</cffunction>

</cfcomponent>

