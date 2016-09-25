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
	key string name;
	{string} characters;
}  

{Character} Characters with characterType in CharacterTypes = ...;

//{string} CharacterNames = all(c in 1..nCharacters) Characters[c];
{string} CharacterNames = union(char in Characters) {char.name};

{string} LeadingCharacters = ...;
int maxNrOfCharacters = ...;

{Scene} Scenes = ...;

assert forall (scene in Scenes, name in scene.characters) test:
	name in CharacterNames;
	
//	character in Characters;
	

dvar int testvar in 1..1000;

dexpr int testexpr = testvar*2;
 
minimize
  testexpr;
subject to {
//	Characters["asdf"].name != Characters["ad"].name;



 	testvar > 10; 
}


execute {
	for(var name in CharacterNames)
   		writeln(name);
}
 