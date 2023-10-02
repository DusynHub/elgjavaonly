package dev.dus.task2_2_1;


public class ZipEndSendEmailRunner {

    public static void main(String[] args) {
        ZipFileRoot zipFileRoot = new ZipFileRoot();
        String root = zipFileRoot.getRootAbsPath();
        String zipFileNamePrefix = zipFileRoot.getProjectName();
        zipFileRoot.zipDirectory(zipFileRoot.getRootAbsPath());
        SendFileToEmail sendFileToEmail = new SendFileToEmail();
        sendFileToEmail.sendFile(root + "/",  zipFileNamePrefix +".zip");
    }
}
