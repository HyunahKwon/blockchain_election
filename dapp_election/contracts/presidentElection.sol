pragma solidity ^0.4.7;

contract presidentElection
{
    mapping(uint => uint) voteCount; 
    mapping(uint => string) candidate; 
    mapping(string => voter) voters;
    uint public numCandidates;
    uint public votePhaseEndTime;
    uint public winnerIndex;
    uint public tieIndex;
    uint public electionID;
    uint public totalVoteCount;
    uint public maxVoteCount;
    uint MIN_VOTE_TIME = 30;
    address public owner;
    address public voteManager;

    struct voter
    {
        uint electionID;
        bool isRegistered;
    }
    
    //Modifiers
    modifier voteUnFinished{
        require(maxVoteCount >= totalVoteCount);
        _;
    }
    modifier voteFinished {
        require(now > votePhaseEndTime);
        _;
    }
    modifier ownerShip{
        require(msg.sender == owner);
        _;
    }
    modifier voterShip{
        require(msg.sender == voteManager);
        _;
    }

    event logString(string);
    event logInt(uint);
    event voteWinner(string, string);

    function presidentElection() {
        owner = msg.sender;
        voteManager = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    }
    

    function startVote(uint _maxVoteCount, uint _votePhaseLengthInSeconds, 
                                  string _choice1, 
                                  string _choice2) public voteFinished ownerShip
    {
        require(_votePhaseLengthInSeconds >= MIN_VOTE_TIME);
        votePhaseEndTime = now + _votePhaseLengthInSeconds;
        resetVoteCount();
        maxVoteCount = _maxVoteCount;
        numCandidates = 2;
        winnerIndex = 0;
        tieIndex = 0;
        candidate[1] = _choice1;
        candidate[2] = _choice2;
        electionID++;
    }

    function resetVoteCount() private
    {
        for (uint i=1; i<=numCandidates; i++)
        {
            voteCount[i] = 0;
        }
        totalVoteCount =0;
    }

    function addCandidate(string _name) public
    {
        require(numCandidates <= 20);
        numCandidates += 1;
        candidate[numCandidates] = _name;
    }

    function register(string _voter) public
    {
        voters[_voter].isRegistered = true;
    }

    function castVote(uint _vote, string _voter) public voteUnFinished
    {
        require(maxVoteCount > totalVoteCount);
        require(!getHasVoted(_voter));
        require(getRegistrationStatus(_voter));
        if (now > votePhaseEndTime) return;

        // record the vote
        if (_vote <= numCandidates) 
        {
            voteCount[_vote] += 1;
            totalVoteCount += 1;
            voters[_voter].electionID = electionID;
            logString("Vote counted.");
        }  
        else 
        {
            logString("Vote could not be read!");
        }
    }

    function countVotes() voteFinished public
    {
        for (uint i=1; i<= numCandidates; i++)
        {
            if (voteCount[i] == voteCount[winnerIndex]) tieIndex = i;
            if (voteCount[i] > voteCount[winnerIndex]) winnerIndex = i;
        }
    }

    function isTie() constant private voteFinished returns(bool)
    {
        if (voteCount[winnerIndex] == voteCount[tieIndex] 
            && winnerIndex != tieIndex
            && winnerIndex != 0
            && tieIndex != 0) return true;
        return false;
    }

    function getWinner() voteFinished constant public returns(string) 
    {
        if (isTie()) return "tie";
        return candidate[winnerIndex];
    }

    function getTieWinner() voteFinished constant public returns(string, string)
    {
        require(isTie());
        return (candidate[winnerIndex], candidate[tieIndex]);
    }

    function intToCandidate(uint _index) constant public returns(string) 
    {
        return candidate[_index];
    }

    function candidateToInt(string _name) constant public returns(uint)
    {
        bytes32 nameHash = sha3(_name);
        for (uint i=1; i<=numCandidates; i++)
        {
            if (nameHash == sha3(candidate[i]))
                return i;
        }
        return 0;
    }

    function getHasVoted(string _voter) constant private returns(bool) 
    {
        return voters[_voter].electionID == electionID;
    }

    function getRegistrationStatus(string _voter) constant private returns(bool)
    {
        return voters[_voter].isRegistered;
    }

    function test(string _name) public returns(string)
    {
        return _name;
    }

}
