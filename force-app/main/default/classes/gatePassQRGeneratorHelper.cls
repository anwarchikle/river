public class gatePassQRGeneratorHelper {

    @future(callout=true)
    public static void generateAndStoreQRCode(String data, String recordId, String productType) {
        Integer xsize = 170;
        Integer ysize = 170;
        try {
            System.debug('Starting QR code generation for recordId: ' + recordId);
            System.debug('Data to encode in QR: ' + data);
            
            String qrApiUrl = System.Label.QRCodeBaseURL 
                + EncodingUtil.urlEncode(data, 'UTF-8') 
                + '&size=' + ysize + 'x' + xsize + '&format=png';

            System.debug('QR API URL: ' + qrApiUrl);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(qrApiUrl);
            request.setMethod('GET');

            HttpResponse response = http.send(request);

            System.debug('QR API response status: ' + response.getStatusCode());

            if (response.getStatusCode() == 200) {
                Blob qrCodeBlob = response.getBodyAsBlob();
                System.debug('QR code image blob size: ' + qrCodeBlob.size());

                Attachment attachment = new Attachment();
                attachment.ParentId = recordId;
                attachment.Name = productType + '_QRCode_' 
                    + System.now().format('yyyyMMdd_HHmmss') + '.pdf';
                attachment.Body = qrCodeBlob;
                attachment.ContentType = 'image/png';

                insert attachment;
                System.debug('Attachment inserted: ' + attachment.Name);

                Order ordToUpdate = new Order(Id = recordId, Is_Gate_Pass_Generated__c = true, Gate_Pass_Generated_Date_Time__c = System.NOW());
                update ordToUpdate;
                System.debug('Order updated to mark QR generated');
            } else {
                System.debug('Failed to get QR code from API. Status: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception caught in generateAndStoreQRCode: ' + e.getMessage());
            ExceptionHelper.createExceptionLog(e);
        }
    }
}