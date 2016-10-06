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
	string name;
	{string} characters;
}  

{Character} Characters with characterType in CharacterTypes = ...;

{string} CharacterNames = union(char in Characters) {char.name};

{string} LeadingCharacters = ...;
int maxNrOfCharacters = ...;

{Scene} Scenes = ...;
int nrOfScenes = card(Scenes);

{Character} nonLeadingChars = {c | c in Characters : c.name not in LeadingCharacters}; 
//float nrCharsPerType[type in CharacterTypes] = card({c | c in nonLeadingChars : (c.characterType == type)});
//float minNrActors = card(LeadingCharacters) + sum(type in CharacterTypes) ceil(nrCharsPerType[type]/maxNrOfCharacters); 
int nrCharsPerType[type in CharacterTypes] = card({c | c in nonLeadingChars : (c.characterType == type)});
int minNrActors = card(LeadingCharacters) + sum(type in CharacterTypes) ((nrCharsPerType[type] + maxNrOfCharacters - 1) div maxNrOfCharacters);
//   ^  this computes the optimal number needed for the play. A solution lower than this is impossible.

//int minNrActors = card(LeadingCharacters) 
//                  + sum(type in CharacterTypes) ((card({c | c in nonLeadingChars : 
//                           (c.characterType == type)}) + maxNrOfCharacters - 1) div maxNrOfCharacters); 

assert forall (scene in Scenes, name in scene.characters) test:
	name in CharacterNames;

// making sure there are enough available actors for the play
range actorRange = 1..card(Characters);
dvar int typeOfActor[actorRange] in 0..nrOfCharacterTypes;
dvar int actorOfCharacter[c in Characters] in actorRange;

dvar int NrOfActorsNeeded;

execute {
	cp.param.Workers = 1;
	  
	cp.param.TimeLimit = 5; 
}
 
minimize
  NrOfActorsNeeded;
subject to {
	//removes unnecessary tests.
	NrOfActorsNeeded >= minNrActors;

	//1 actor cannot play more than MAX number of chars
	forall(a in actorRange) count(actorOfCharacter, a) <= maxNrOfCharacters;

	// Leading characters are played by the actors in the begining of the list.
	forall(lc in LeadingCharacters)
	  	actorOfCharacter[<lc>] == (ord(LeadingCharacters, lc))+1;

	//1 leading character -> 1 actor
	forall(lc in LeadingCharacters, c in Characters : lc != c.name)
		actorOfCharacter[<lc>] != actorOfCharacter[<c.name>];
	
	//This assures that no actor plays two charachters in the same scene.
	//1 scene -> an actor only plays 1 char
	//1 character can only be played by 1 actor
	forall(s in Scenes, char1 in s.characters, char2 in s.characters: char1 != char2)
		actorOfCharacter[<char1>] != actorOfCharacter[<char2>]; 
	  
	//constraint based on the minimization requirement
	forall(char in Characters)
	    actorOfCharacter[<char.name>] <= NrOfActorsNeeded;
	    
//actor can only play a character if they have the same type
	forall(char in Characters)
	  typeOfActor[actorOfCharacter[<char.name>]] == (ord(CharacterTypes, char.characterType));


// 1 actor cannot play 2 different characters in 2 consecutive scenes 
// can only play the same character in 2 consecutive scenes
// for each scene, for each character in the scene * for each character in scene 
// before that, if characters are different -> different actors	
	forall (s2 in 1..nrOfScenes-1)
		forall(ch2 in item(Scenes, s2).characters, ch1 in item(Scenes, s2 - 1).characters : ch1 != ch2)	
			actorOfCharacter[<ch1>] != actorOfCharacter[<ch2>];
}

//	fill in from the decision variables.
int nrOfActorsOfType[ct in CharacterTypes];

//	fill in from the decision variables.
{Character} CharactersPlayedByActor[i in 0..NrOfActorsNeeded-1];

execute {
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
