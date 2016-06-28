:- use_module(library(system)).

test_strategy(N, FirstPlayerStrategy, SecondPlayerStrategy) :-
	playTracker(N, FirstPlayerStrategy, SecondPlayerStrategy, AllMoves, AllWinners, AllTimes),
	countOccur(b, AllWinners, BWins),
	write(FirstPlayerStrategy), write(': Times Blue wins '), write(BWins), write('\n'),
	countOccur(r, AllWinners, RWins),
	write(SecondPlayerStrategy), write(': Times Red wins '), write(RWins), write('\n'),
	countOccur(draw, AllWinners, Draws),
	write('draw '), write(Draws), write('\n'),
	countOccur(stalemate, AllWinners, Stalemates),
	write('stalemates '), write(Stalemates), write('\n'),
	countOccur(exhaust, AllWinners, ExhaustedDraws),
	write('exhausts '), write(ExhaustedDraws), write('\n'),
	NoWinnerCount is Draws + Stalemates + ExhaustedDraws,
	write('Times neither wins (draw/stalemate/exhausted draw) '), write(NoWinnerCount), write('\n'),
	max(AllMoves, MaxMoves),
	write('Most moves in a single game '), write(MaxMoves), write('\n'),
	min(AllMoves, MinMoves),
	write('Least moves in a single game '), write(MinMoves), write('\n'),
	avg(AllMoves, AvgMoves),
	write('Average moves per game '), write(AvgMoves), write('\n'),
	avg(AllTimes, AvgTime),
	write('Averge (wall clock) time per game '), write(AvgTime), write('\n').

	
playTracker(0, _, _, [], [], []).

playTracker(N, FirstPlayerStrategy, SecondPlayerStrategy, [Moves|AllMoves], [Winner|AllWinners], [RunTime|AllTimes]) :-
	N > 0,
	now(StartTime),
	play(quiet, FirstPlayerStrategy, SecondPlayerStrategy, Moves, Winner),
	now(EndTime),
	RunTime is EndTime - StartTime, 
	NewN is N - 1,
	write(NewN), write(' '),
	playTracker(NewN, FirstPlayerStrategy, SecondPlayerStrategy, AllMoves, AllWinners, AllTimes).



%%%%%%%%%%%%%%%%%%%
%%% BLOODLUST %%%%%
%%%%%%%%%%%%%%%%%%%

%BLOODLUST BLUE
bloodlust('b', [AliveBlues, AliveReds], [NewAliveBlues, AliveReds], BestMove) :-
	poss_moves('b', [AliveBlues, AliveReds], PossMoves),
	best_move('b', bloodlust, [AliveBlues, AliveReds], PossMoves, BestMove),
	alter_board(BestMove, AliveBlues, NewAliveBlues).

best_move('b', bloodlust, [AliveBlues, AliveReds], PossMoves, BestMove) :-
	PossMoves = [NextMove|RestMoves],
	alter_board(NextMove, AliveBlues, NewAliveBlues),
	next_generation([NewAliveBlues, AliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveReds, NewScore),
	acc_best_move('b', bloodlust, [AliveBlues, AliveReds], RestMoves, NextMove, NewScore, BestMove).

acc_best_move('b',bloodlust , _, [], A, _, A).

acc_best_move('b', bloodlust, [AliveBlues, AliveReds],  [NextMove|RestMoves], A, BestScore, BestMove) :-
	alter_board(NextMove, AliveBlues, NewAliveBlues),
	next_generation([NewAliveBlues, AliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveReds, NewScore),
	(NewScore < BestScore -> acc_best_move('b', bloodlust, [AliveBlues, AliveReds] , RestMoves, NextMove, NewScore, BestMove);
		acc_best_move('b', bloodlust, [AliveBlues, AliveReds] , RestMoves, A, BestScore, BestMove)).

%BLOODLUST RED
bloodlust('r', [AliveBlues, AliveReds], [AliveBlues, NewAliveReds], BestMove) :-
	poss_moves('r', [AliveBlues, AliveReds], PossMoves),
	best_move('r', bloodlust, [AliveBlues, AliveReds], PossMoves, BestMove),
	alter_board(BestMove, AliveReds, NewAliveReds).

best_move('r', bloodlust, [AliveBlues, AliveReds], PossMoves, BestMove) :-
	PossMoves = [NextMove|RestMoves],
	alter_board(NextMove, AliveReds, NewAliveReds),
	next_generation([AliveBlues, NewAliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveBlues, NewScore),
	acc_best_move('r', bloodlust, [AliveBlues, AliveReds], RestMoves, NextMove, NewScore, BestMove).

acc_best_move('r',bloodlust , _, [], A, _, A).

acc_best_move('r', bloodlust, [AliveBlues, AliveReds],  [NextMove|RestMoves], A, BestScore, BestMove) :-
	alter_board(NextMove, AliveReds, NewAliveReds),
	next_generation([AliveBlues, NewAliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveBlues, NewScore),
	(NewScore < BestScore -> acc_best_move('r', bloodlust, [AliveBlues, AliveReds] , RestMoves, NextMove, NewScore, BestMove);
		acc_best_move('r', bloodlust, [AliveBlues, AliveReds] , RestMoves, A, BestScore, BestMove)).



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SELF PRESERVATION %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%SELF PRESERVATION BLUE
self_preservation('b', [AliveBlues, AliveReds], [NewAliveBlues, AliveReds], BestMove) :-
	poss_moves('b', [AliveBlues, AliveReds], PossMoves),
	best_move('b', self_preservation, [AliveBlues, AliveReds], PossMoves, BestMove),
	alter_board(BestMove, AliveBlues, NewAliveBlues).

best_move('b', self_preservation, [AliveBlues, AliveReds], PossMoves, BestMove) :-
	PossMoves = [NextMove|RestMoves],
	alter_board(NextMove, AliveBlues, NewAliveBlues),
	next_generation([NewAliveBlues, AliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveBlues, NewScore),
	acc_best_move('b', self_preservation, [AliveBlues, AliveReds], RestMoves, NextMove, NewScore, BestMove).

acc_best_move('b', self_preservation, _, [], A, _, A).

acc_best_move('b', self_preservation, [AliveBlues, AliveReds],  [NextMove|RestMoves], A, BestScore, BestMove) :-
	alter_board(NextMove, AliveBlues, NewAliveBlues),
	next_generation([NewAliveBlues, AliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveBlues, NewScore),
	(NewScore > BestScore -> acc_best_move('b', self_preservation, [AliveBlues, AliveReds] , RestMoves, NextMove, NewScore, BestMove);
		acc_best_move('b', self_preservation, [AliveBlues, AliveReds] , RestMoves, A, BestScore, BestMove)).

%SELF PRESERVATION RED
self_preservation('r', [AliveBlues, AliveReds], [AliveBlues, NewAliveReds], BestMove) :-
	poss_moves('r', [AliveBlues, AliveReds], PossMoves),
	best_move('r', self_preservation, [AliveBlues, AliveReds], PossMoves, BestMove),
	alter_board(BestMove, AliveReds, NewAliveReds).

best_move('r', self_preservation, [AliveBlues, AliveReds], PossMoves, BestMove) :-
	PossMoves = [NextMove|RestMoves],
	alter_board(NextMove, AliveBlues, NewAliveBlues),
	next_generation([NewAliveBlues, AliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveReds, NewScore),
	acc_best_move('r', self_preservation, [AliveBlues, AliveReds], RestMoves, NextMove, NewScore, BestMove).

acc_best_move('r', self_preservation, _, [], A, _, A).

acc_best_move('r', self_preservation, [AliveBlues, AliveReds],  [NextMove|RestMoves], A, BestScore, BestMove) :-
	alter_board(NextMove, AliveReds, NewAliveReds),
	next_generation([AliveBlues, NewAliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveReds, NewScore),
	(NewScore > BestScore -> acc_best_move('r', self_preservation, [AliveBlues, AliveReds] , RestMoves, NextMove, NewScore, BestMove);
		acc_best_move('r', self_preservation, [AliveBlues, AliveReds] , RestMoves, A, BestScore, BestMove)).



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% LAND GRAB %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%LAND GRAB BLUE
land_grab('b', [AliveBlues, AliveReds], [NewAliveBlues, AliveReds], BestMove) :-
	poss_moves('b', [AliveBlues, AliveReds], PossMoves),
	best_move('b', land_grab, [AliveBlues, AliveReds], PossMoves, BestMove),
	alter_board(BestMove, AliveBlues, NewAliveBlues).

best_move('b', land_grab, [AliveBlues, AliveReds], PossMoves, BestMove) :-
	PossMoves = [NextMove|RestMoves],
	alter_board(NextMove, AliveBlues, NewAliveBlues),
	next_generation([NewAliveBlues, AliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveBlues, BlueLength),
	len(NewCrankedAliveReds, RedLength),
	NewScore is BlueLength - RedLength,
	acc_best_move('b', land_grab, [AliveBlues, AliveReds], RestMoves, NextMove, NewScore, BestMove).

acc_best_move('b', land_grab, _, [], A, _, A).

acc_best_move('b', land_grab, [AliveBlues, AliveReds],  [NextMove|RestMoves], A, BestScore, BestMove) :-
	alter_board(NextMove, AliveBlues, NewAliveBlues),
	next_generation([NewAliveBlues, AliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveBlues, BlueLength),
	len(NewCrankedAliveReds, RedLength),
	NewScore is BlueLength - RedLength,
	(NewScore > BestScore -> acc_best_move('b', land_grab, [AliveBlues, AliveReds] , RestMoves, NextMove, NewScore, BestMove);
		acc_best_move('b', land_grab, [AliveBlues, AliveReds] , RestMoves, A, BestScore, BestMove)).	

%LAND GRAB RED
land_grab('r', [AliveBlues, AliveReds], [AliveBlues, NewAliveReds], BestMove) :-
	poss_moves('r', [AliveBlues, AliveReds], PossMoves),
	best_move('r', land_grab, [AliveBlues, AliveReds], PossMoves, BestMove),
	alter_board(BestMove, AliveReds, NewAliveReds).

best_move('r', land_grab, [AliveBlues, AliveReds], PossMoves, BestMove) :-
	PossMoves = [NextMove|RestMoves],
	alter_board(NextMove, AliveBlues, NewAliveBlues),
	next_generation([NewAliveBlues, AliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveBlues, BlueLength),
	len(NewCrankedAliveReds, RedLength),
	NewScore is RedLength - BlueLength,
	acc_best_move('r', land_grab, [AliveBlues, AliveReds], RestMoves, NextMove, NewScore, BestMove).

acc_best_move('r', land_grab, _, [], A, _, A).

acc_best_move('r', land_grab, [AliveBlues, AliveReds],  [NextMove|RestMoves], A, BestScore, BestMove) :-
	alter_board(NextMove, AliveReds, NewAliveReds),
	next_generation([AliveBlues, NewAliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	len(NewCrankedAliveBlues, BlueLength),
	len(NewCrankedAliveReds, RedLength),
	NewScore is  RedLength - BlueLength,
	(NewScore > BestScore -> acc_best_move('r', land_grab, [AliveBlues, AliveReds] , RestMoves, NextMove, NewScore, BestMove);
		acc_best_move('r', land_grab, [AliveBlues, AliveReds] , RestMoves, A, BestScore, BestMove)).	



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% MINIMAX %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%MINIMAX BLUE
minimax('b', [AliveBlues, AliveReds], [NewAliveBlues, AliveReds], BestMove) :-
	poss_moves('b', [AliveBlues, AliveReds], PossMoves),
	best_move('b', minimax, [AliveBlues, AliveReds], PossMoves, BestMove),
	alter_board(BestMove, AliveBlues, NewAliveBlues).

best_move('b', minimax, [AliveBlues, AliveReds], PossMoves, BestMove) :-
	PossMoves = [NextMove|RestMoves],
	alter_board(NextMove, AliveBlues, NewAliveBlues),
	next_generation([NewAliveBlues, AliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	move_piece('r', land_grab, [NewCrankedAliveBlues, NewCrankedAliveReds], [SecondCrankAliveBlues, SecondCrankAliveReds], OpponentMove),	
	len(SecondCrankAliveBlues, BlueLength),
	len(SecondCrankAliveReds, RedLength),
	NewScore is BlueLength - RedLength,
	acc_best_move('b', minimax, [AliveBlues, AliveReds], RestMoves, NextMove, NewScore, BestMove).

acc_best_move('b', minimax, _,  [], A, _, A).

acc_best_move('b', minimax, [AliveBlues, AliveReds],  [NextMove|RestMoves], A, BestScore, BestMove) :-
	alter_board(NextMove, AliveBlues, NewAliveBlues),
	next_generation([NewAliveBlues, AliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	move_piece('r', land_grab, [NewCrankedAliveBlues, NewCrankedAliveReds], [SecondCrankAliveBlues, SecondCrankAliveReds], OpponentMove),
	len(SecondCrankAliveBlues, BlueLength),
	len(SecondCrankAliveReds, RedLength),
	NewScore is BlueLength - RedLength,
	(NewScore > BestScore -> acc_best_move('b', minimax, [AliveBlues, AliveReds], RestMoves, NextMove, NewScore, BestMove) ;
			acc_best_move('b', minimax, [AliveBlues, AliveReds], RestMoves, A, BestScore, BestMove)).

%MINIMAX RED
minimax('r', [AliveBlues, AliveReds], [AliveBlues, NewAliveReds], BestMove) :-
	poss_moves('r', [AliveBlues, AliveReds], PossMoves),
	best_move('r', minimax, [AliveBlues, AliveReds], PossMoves, BestMove),
	alter_board(BestMove, AliveReds, NewAliveReds).

best_move('r', minimax, [AliveBlues, AliveReds], PossMoves, BestMove) :-
	PossMoves = [NextMove|RestMoves],
	alter_board(NextMove, AliveReds, NewAliveReds),
	next_generation([AliveBlues, NewAliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	move_piece('b', land_grab,  [NewCrankedAliveBlues, NewCrankedAliveReds], [SecondCrankAliveBlues, SecondCrankAliveReds], OpponentMove),
	len(SecondCrankAliveBlues, BlueLength),
	len(SecondCrankAliveReds, RedLength),
	NewScore is  RedLength - BlueLength,
	acc_best_move('r', minimax, [AliveBlues, AliveReds], RestMoves, NextMove, NewScore, BestMove).

acc_best_move('r', minimax, _, [], A, _, A).

acc_best_move('r', minimax, [AliveBlues, AliveReds],  [NextMove|RestMoves], A, BestScore, BestMove) :-
	alter_board(NextMove, AliveReds, NewAliveReds),
	next_generation([AliveBlues, NewAliveReds], [NewCrankedAliveBlues, NewCrankedAliveReds]),
	move_piece('b', land_grab,  [NewCrankedAliveBlues, NewCrankedAliveReds], [SecondCrankAliveBlues, SecondCrankAliveReds], OpponentMove),
	len(SecondCrankAliveBlues, BlueLength),
	len(SecondCrankAliveReds, RedLength),
	NewScore is  RedLength - BlueLength,
	(NewScore > BestScore -> acc_best_move('r', minimax, [AliveBlues, AliveReds], RestMoves, NextMove, NewScore, BestMove) ;
			acc_best_move('r', minimax, [AliveBlues, AliveReds], RestMoves, A, BestScore, BestMove)).



%%%%%%%%%%%%%%%%%%%%%
% HELPER FUNCTIONS %%
%%%%%%%%%%%%%%%%%%%%%

%FIND ALL POSSIBLE MOVES
poss_moves('b', [Blues,Reds], PossMoves) :-
	findall([A,B,MA,MB],
			(member([A,B], Blues),
				neighbour_position(A,B,[MA,MB]),
	        	\+member([MA,MB],Blues),
	        	\+member([MA,MB],Reds)
			),
	 		PossMoves).
 
poss_moves('r', [Blues,Reds], PossMoves) :-
	findall([A,B,MA,MB],
			(member([A,B], Reds),
				neighbour_position(A,B,[MA,MB]),
	        	\+member([MA,MB],Blues),
	        	\+member([MA,MB],Reds)
			),
	 		PossMoves).

%MAX
max(List, Max) :-
	List = [H|T],
	accMax(T, H, Max).

accMax([],A,A).

accMax([H|T], A, Max) :-
	H > A,
	accMax(T, H, Max).

accMax([H|T], A, Max) :-
	H =< A,
	accMax(T, A, Max).

%MIN
min(List, Min) :-
	List = [H|T],
	accMin(T, H, Min).

accMin([], A, A).

accMin([H|T], A, Min) :-
	H < A,
	accMin(T, H, Min).

accMin([H|T], A, Min) :-
	H >= A,
	accMin(T, A, Min).

%AVG
avg(List,Avg) :-
	len(List, N),
	sum(List, Total),
	Avg is Total / N.

%COUNT OCCURRENCES
countOccur(Item, List, Count) :-
	accCountOccur(Item, List, 0, Count).

accCountOccur(_, [], A, A).

accCountOccur(Item, [Item|T] , A, Count) :-
	ANew is A + 1,
	accCountOccur(Item, T, ANew, Count).

accCountOccur(Item, [H|T], A, Count) :-
	Item \= H,
	accCountOccur(Item, T, A, Count).

%LENGTH
len(List, Length) :-
	accLen(List, 0, Length).

accLen([], A, A).

accLen([_|T], A, Length) :-
	ANew is A + 1,
	accLen(T, ANew, Length).

%SUM
sum(List, Sum) :-
	accSum(List, 0, Sum).

accSum([], A, A).

accSum([H|T], A, Sum) :-
	ANew is A + H,
	accSum(T, ANew, Sum).
