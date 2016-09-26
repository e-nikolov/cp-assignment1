/*********************************************
 * OPL 12.6.3.0 Model
 * Author: enikolov
 * Creation Date: 25 Sep 2016 at 18:53:19
 *********************************************/

using CP;

{string} CharacterTypes = ...;
int nrOfCharacterTypes = card(CharacterTypes);

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
int nrOfScenes = card(Scenes);

assert forall (scene in Scenes, name in scene.characters) test:
	name in CharacterNames;
	
range actorRange = 1..card(Characters);
dvar int typeOfActor[actorRange] in 0..nrOfCharacterTypes;
dvar int actorOfCharacter[c in Characters] in actorRange;

dexpr int NrOfActorsNeeded = max(c in Characters) actorOfCharacter[c];;
 
execute {
	cp.param.Workers = 1;
	  
	cp.param.TimeLimit = 5; 
} 
 
minimize
  NrOfActorsNeeded;
subject to {
	//This assures that no actor plays two charachters in the same scene.
	//1 scene -> an actor only plays 1 char
	//1 character can only be played by 1 actor
	forall(s in Scenes, char1 in s.characters, char2 in s.characters: char1 != char2)
		actorOfCharacter[<char1>] != actorOfCharacter[<char2>]; 
	  

//actor can play a character if they have the same type
	forall(char in Characters)
	  typeOfActor[actorOfCharacter[<char.name>]] == (ord(CharacterTypes, char.characterType));

//1 leading character -> 1 actor
	forall(lc in LeadingCharacters, c in Characters : lc != c.name)
	  actorOfCharacter[<lc>] != actorOfCharacter[<c.name>];
//1 actor cannot play 2 different characters in 2 consecutive scenes / can only play the same character in 2 consecutive scenes

	// for each scene
	
	// for each character in the scene * for each character in scene before that, if characters are different -> different actors
	
	forall (s2 in 1..nrOfScenes-1)
//	  	allDifferent(all(s1 in Slots : s <= s1 <= s+blocksize-1) cartype[s1]);
//		allDifferent(all(s in s2-1..s2, ch in item(Scenes, s).characters) actorOfCharacter[<ch>]);
		forall(ch2 in item(Scenes, s2).characters, ch1 in item(Scenes, s2 - 1).characters : ch1 != ch2)	
			actorOfCharacter[<ch1>] != actorOfCharacter[<ch2>];
//1 actor cannot play more than MAX number of chars
	forall(a in actorRange) count(actorOfCharacter, a) <= maxNrOfCharacters;
}

execute {
//	for(var name in CharacterNames)
//   		writeln(name);
}

//{Character} CharactersPlayedByActor[i in 0..NrOfActorsNeeded-1] = 
//	fill in from your decision variables.

int nrOfActorsOfType[ct in CharacterTypes];
//	fill in from your decision variables.
//

{Character} CharactersPlayedByActor[i in 0..NrOfActorsNeeded-1];

execute {
//CharactersPlayedByActor = "asdf";

	for(var ch in Characters) {
		CharactersPlayedByActor[actorOfCharacter[ch]-1].add(ch);	
	}
	
	for(var i = 0; i < NrOfActorsNeeded; ++i) {	
		nrOfActorsOfType[Opl.item(CharacterTypes, typeOfActor[i+1])]++;
	}

	

  	writeln("Actors needed: ", NrOfActorsNeeded);
  	
  	for(var ct in CharacterTypes) {
  		writeln(ct, " needed: ", nrOfActorsOfType[ct]);
   	}  	  
   			     	
  	for(var i=0; i<NrOfActorsNeeded; i++) {
  	  writeln("Actor ", i, " plays ", CharactersPlayedByActor[i]);
    }  	  
}  
