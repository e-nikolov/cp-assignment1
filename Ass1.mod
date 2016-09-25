/*********************************************
 * OPL 12.6.3.0 Model
 * Author: enikolov
 * Creation Date: 25 Sep 2016 at 18:53:19
 *********************************************/

using CP;

{string} CharacterTypes = ...;

tuple Character {
	string name;
	string characterType; 
}

tuple Scene {
	string name;
	{string} characters;
}  

{Character} Characters with characterType in CharacterTypes = ...;

{string} LeadingCharacters = ...;
int maxNrOfCharacters = ...;

{Scene} Scenes = ...;

dvar int testvar in 1..1000;

dexpr int testexpr = testvar*2;
 
minimize
  testexpr;
subject to {


 	testvar > 10; 
}
 