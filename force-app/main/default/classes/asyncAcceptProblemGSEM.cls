/***
created by: Yesha Benegal
To run queuable job for OEM flow
****/

public class asyncAcceptProblemGSEM implements Queueable {

    private string caseNumber;
    public asyncAcceptProblemGSEM (string requesterID, string caseNumber, string phoneNumber, Id gsemId) {
        system.debug(' *** in asyncAcceptProblemGSEM  ' + caseNumber);
        p2nToGSEM.acceptproblemCase(requesterID, caseNumber, phoneNumber, gsemId);
              
    }
    public void execute(QueueableContext context) {
        system.debug(' case AP Problem');                   
    }
    
    
}