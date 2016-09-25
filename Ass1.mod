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

{string} CharacterNames = union(char in Characters) {char.name};

{string} LeadingCharacters = ...;
int maxNrOfCharacters = ...;

{Scene} Scenes = ...;

assert forall (scene in Scenes, name in scene.characters) test:
	name in CharacterNames;
	
range actorRange = 1..card(Characters);
dvar int Actors[actorRange] in 0..1;
dvar int assign[Characters] in actorRange;

dvar int testvar in 1..1000;

dexpr int testexpr = testvar*2;
 
minimize
  testexpr;
subject to {
	//This assures that no actor plays two charachters in the same scene.
	//1 scene -> an actor only plays 1 char
	forall(s in Scenes, char1 in s.characters, char2 in s.characters: char1 != char2)
		assign[<char1>] != assign[<char2>]; 
	  
//1 character can only be played by 1 actor

//actor can play a character if they have the same type

//1 leading character -> 1 actor

//1 actor cannot play 2 different characters in 2 consecutive scenes / can only play the same character in 2 consecutive scenes

//1 actor cannot play more than MAX number of chars

 	testvar > 10; 
}


execute {
	for(var name in CharacterNames)
   		writeln(name);
}
