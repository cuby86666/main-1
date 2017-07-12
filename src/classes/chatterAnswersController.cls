public class chatterAnswersController {

    //<!-- Note : Change the userType to the site name if we push this to production, right now its hardcoded as TestSite-->
    public string usertype {get;set;}
    public String ft { get; set; }

    public String ct { get; set; }

    public String pc { get; set; }

    public String ps { get; set; }
    
    //community Id
    public string communityID { get; set;}

    public String getTb() {
        return null;
    }


    public String ex { get; set; }
    public List<chatterAnswersActivity> cAnsAct {get;set;}
    public List<scoreWrapper> theScores {get;set;}
    public integer topScore {get;set;}
    public Map<String,Integer> userScoreMap {get;set;}
    public List<scoreWrapper> topScorers {get;set;}
    public List<Integer> topScores {get;set;}
    public Integer topScoreCounter {get;set;}
    
    public Map<String,Integer> topScorersMap {get;set;}
    public List<User> topUserInfo {get;set;}
    public List<finalScoreWrapper> finalScoreBoardInfo {get;set;}
    public List<Question> qUrl {get;set;}
    
    public chatterAnswersController(){
        usertype = userinfo.getusertype();
        if(userType == 'Guest')
            userType = '/community/';
        else
            userType = '';
        finalScoreBoardInfo = new List<finalScoreWrapper>();
        topScorersMap = new Map<String,Integer>();
        cAnsAct = new List<chatterAnswersActivity>();
        theScores = new List<scoreWrapper>();
        userScoreMap = new Map<String,Integer>();
        topScorers = new List<scoreWrapper>();
        topScores = new List<Integer>();
        Map<string,string> MapofCommunitynameandIds = new Map<string,string>();
        MapofCommunitynameandIds.put('Amplifiers','09aD0000000gXbT');
        MapofCommunitynameandIds.put('CATVHybrids','09aD0000000gXbY');
        MapofCommunitynameandIds.put('Diodes','09aD0000000gXbd');
        MapofCommunitynameandIds.put('Mixers','09aD0000000gXbn');
        MapofCommunitynameandIds.put('PLLsandOscillators','09aD0000000gXbi');
        MapofCommunitynameandIds.put('Transistors','09aD0000000gXbs');
        MapofCommunitynameandIds.put('EngineersCorner','09aD0000000gXda');
        
        
        //To use this in page to dynamically get the community id based on the page 
        //get the community id of current page
        string pageName = ApexPages.currentPage().getUrl();
        integer mindex = pageName.lastindexof('/');
        integer lindex = pageName.indexof('?',mindex);
        if(lindex == -1)
            pageName = pageName.substring(mindex+1,pagename.length());
        else
            pageName = pageName.substring(mindex+1,lindex);
        if(MapofCommunitynameandIds.containsKey(pageName))
            communityID =  MapofCommunitynameandIds.get(pageName);
        
            
        topScoreCounter=0;
        userScoreMap  = new Map<String,Integer>();
      //We exclude the user 005x0000000E6j2 because it's an agent. Ideally we would check if the user has an account or not (NULL vs !Null) and remove any user without an account.
      // where UserId != '005x0000000E6j2'
        cAnsAct = [
                    select ca.BestAnswerReceivedCount, ca.QuestionUpVotesReceivedCount, ca.UserId
                    from chatterAnswersActivity ca
                    where UserId IN (select Id from User where AccountID != '')
                    and (BestAnswerReceivedCount > 0 or QuestionUpVotesReceivedCount > 0)
                    order by ca.BestAnswerReceivedCount Desc
                    LIMIT 5                  
                  ];
                  
        if(cAnsAct.size() > 0){
            calculateScores();
            calculateFinalScores();
        }         
    }
    
    public void calculateScores(){
        for(chatterAnswersActivity caa: cAnsAct){
            theScores.add(new scoreWrapper(((caa.QuestionUpVotesReceivedCount * 5) + (caa.BestAnswerReceivedCount * 20)), caa.userId));
        }
    }
    
    public void calculateFinalScores(){        
        for( scoreWrapper sw: theScores){
            if(userScoreMap.containsKey(sw.uId)){
                userScoreMap.put(sw.uId,userScoreMap.get(sw.uId)+sw.score);
            }else{
                userScoreMap.put(sw.uId,sw.score);
            }          
        }
        
        List<Integer> tempList = new List<Integer>();
        tempList = userScoreMap.values();
        tempList.sort();
        topScores = new List<Integer>();
        if(tempList.size() < 11){
            for(Integer i = tempList.size()-1;i > -1;i--){
                topScores.add(tempList[i]);
            }
        }else{
            for(Integer j = 10; j > 1; j--){
                topScores.add(tempList[j]);
            }
        }
        Map<String,String> IdStopper = new Map<String,String>();
        Integer tempScore;
        for(Integer i : topScores){
            for( String mapKey : userScoreMap.keySet()){               
                if(topScoreCounter < 11){
                    tempScore = userScoreMap.get(mapKey);                        
                    if( tempScore == i ){
                        if(IdStopper.containsKey(mapKey)){
                            break;
                        }
                        topScorers.add(new scoreWrapper(tempScore, mapKey));
                        topScoreCounter++;
                        IdStopper.put(mapKey,mapKey);
                    }
                }else{
                    break;
                }
            }
        }

        integer initialRank = 1;
        for(scoreWrapper sw : topScorers){
            topScorersMap.put(sw.uId , initialRank);
            initialRank++;
        }
        
        topUserInfo = [select Id, Name, FullPhotoUrl From User where Id IN: topScorersMap.keySet()];
        qUrl = [select CreatorSmallPhotoUrl, CreatedById from Question where CreatedById IN: topScorersMap.keySet()];
        
        Map<string,string> passQurl = new Map<String,String>();
        
        for(Question q : qUrl){
            if(!passQurl.containsKey(q.CreatedById)){
                passQurl.put(q.CreatedById , q.CreatorSmallPhotoUrl);
            }
        }
        
        integer positionCounter = 0;
        integer rank = 1;
        for(string uId : topScorersMap.keySet()){
            for(User u : topUserInfo){           
                if(topScorersMap.get(u.Id) == rank){
                    finalScoreBoardInfo.add(new finalScoreWrapper(passQurl.get(u.Id), u.Name, userScoreMap.get(u.Id), rank));
                    rank++;               
                }
            }
        }
    }
    
    public class scoreWrapper{
        public integer score {get;set;}
        public string uId {get;set;}
        
        public scoreWrapper(integer sc, string id){
            score = sc;
            uId = id;
        }
    }
    
    public class finalScoreWrapper{
        public string photoURL {get;set;}
        public string personName {get;set;}
        public integer personScore {get;set;}
        public integer RankNo {get;set;}
        
        public finalScoreWrapper(string url, string pName, integer fScore, integer r){
            photoURL = url;
            personName = pName;
            personScore = fScore;
            RankNo = r;
        }
    }
}