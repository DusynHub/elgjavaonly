package dev.dus.task2_2_1;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.activation.FileDataSource;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.io.File;
import java.util.Properties;

public class SendFileToEmail {

    private static final String FROM_EMAIL = "fromduselgtest@mail.ru";
    private static final String FROM_PASSWORD = "fJ1TbhnB2K9yAWe5pcmY";
    private static final String TO_EMAIL = "masfuj@yandex.ru";


    /**
     * Sends an email with a file attachment.
     *
     * @param filePath The path to the file to attach.
     * @param fileName The name of the file to attach.
     */
    public void sendFile(String filePath, String fileName){
        Properties properties = new Properties();
        properties.put("mail.smtp.host", "smtp.mail.ru");
        properties.put("mail.smtp.port", "465");
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtps.ssl.checkserveridentity", true);
        properties.put("mail.smtps.ssl.trust", "*");
        properties.put("mail.smtp.ssl.enable", "true");

        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, FROM_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(TO_EMAIL));
            message.setSubject("Your Email Subject");

            DataSource dataSource = new FileDataSource(new File(filePath + fileName));
            DataHandler dataHandler = new DataHandler(dataSource);
            message.setDataHandler(dataHandler);
            message.setFileName(fileName);

            Transport.send(message);
            System.out.println("Email sent successfully");
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
}
