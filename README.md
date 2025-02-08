# ThreeCardGambling
This is an original three-card gambling game made with Godot 4.3.

## Rules
The rules are simple. Every game has three turns. 
At the beginning of every game, each player draws 7 cards, and then play 3 of them on the table. 
The cards are compared based on the types first: "straight flush > three of a kind > straight > flush > two of a kind > high cards"; 
if types are the same, then compare the highest card point; 
if the card point is the same, then compare the suit based on "spades > hearts > clubs > diamonds".
At the beginning of the second and the third turn, each player draws a new card.
A player wins the game if he/she wins two of the three turns.

The UIs are currently in Chinese, but the rules should be self-evident. 
The AI opponent currently is a naive opponent that plays three cards randomly.
