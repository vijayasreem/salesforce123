/**
* @File Name          : EmailMessageHelper.cls
* @Description        : Helper class to send emails
* @Author             : Appshark 
* @Group              : 
* @Last Modified By    : Appshark
* @Last Modified On    : 9/9/2022
* @Modification Log    : 
* *==================================================================================================
*/
public class EmailMessageHelper {
    
    public static map<String,String> SendCsvEmail(String CsvData)
    {
        System.debug('CsvData' +CsvData); 
        map<String, String> result = new map<String, String> ();
        try
        {
            list<String> toAddresses = new list<String>();
            String customLabelToAddress = Label.To_Email_Addresses_For_Invoice;
            Blob csvBlob = blob.valueOf(CsvData);
            datetime dLastdayofTheMonth = system.today().toStartOfMonth().addDays(-1);
            System.debug('dLastdayofTheMonth' +dLastdayofTheMonth.Year()+'-'+dLastdayofTheMonth.month()+'-'+dLastdayofTheMonth.day()); 
            //string d = dLastdayofTheMonth.date().format();
            //datetime LastMonthFormattedDate = datetime.valueof(d);
            String csvName = 'AESOP_FlatFeeBillings_'+system.now()+'_'+dLastdayofTheMonth.Year()+'-'+dLastdayofTheMonth.month()+'-'+dLastdayofTheMonth.day()+'.CSV';
            //datetime d = dLastdayofTheMonth;
            String subject = dLastdayofTheMonth.format('MMM')+' '+ system.today().Year()+ ' AESOP Claims Billing Summary';
            string strBody = 'Hello All, '+'\n\n' ;
            strBody += 'Attached is our ' +dLastdayofTheMonth.format('MMM') +'-'+dLastdayofTheMonth.Year() +' AESOP Claims Billing Summary.'+'\n\n';
            strBody += 'Thanks, '+'\n';
            strBody += 'AESOP'; 
            
            if(customLabelToAddress != null && customLabelToAddress.contains(','))  
                toAddresses.addall(customLabelToAddress.split(','));
            else 
                toAddresses.add(customLabelToAddress);
            
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody(strBody);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            if (r[0].success) {
                System.debug('The email was sent successfully.');
                result.put('SUCCESS', 'The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + r[0].errors[0].message);
                result.put('ERROR', 'The email failed to send: ' + r[0].errors[0].message);
            }
        }
        catch(Exception EX)
        {
            GDSException.LogException(ex);
            System.debug('The email failed to send: ' + Ex.getMessage());
            result.put('ERROR', 'The email failed to send: ' + Ex.getMessage());
        }
        return result;
    }
    
}