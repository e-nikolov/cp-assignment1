/*********************************************
 * OPL 12.6.3.0 Model
 * Author: enikolov
 * Creation Date: 25 Sep 2016 at 18:53:19
 *********************************************/

using CP;

{string} CharacterTypes = ...;

tuple Character {
	key string name;
	string characterType; 
}

tuple Scene {
	key string name;
	{string} characters;
}  

{Character} Characters with characterType in CharacterTypes = ...;

{string} LeadingCharacters = ...;
int maxNrOfCharacters = ...;

{Scene} Scenes = ...;

range actorRange = 1..card(Characters);
dvar int Actors[actorRange] in 0..1;
dvar int assign[Characters] in actorRange;

dvar int testvar in 1..1000;

dexpr int testexpr = testvar*2;
 
minimize
  testexpr;
subject to {
	forall(s in Scenes, char1 in s.characters, char2 in s.characters: char1 != char2)
		assign[<char1>] != assign[<char2>]; 
	  
	testvar > 10; 
}