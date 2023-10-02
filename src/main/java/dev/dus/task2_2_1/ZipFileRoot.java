package dev.dus.task2_2_1;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * A class that provides methods to zip and send files in root directory of "ZipFileRoot.class" as emails.
 */
public class ZipFileRoot {

    List<String> filesListInDir = new ArrayList<>();

    /**
     * Gets the absolute path of the root directory.
     *
     * @return The absolute path of the root directory.
     */
    public String getRootAbsPath(){
        return Paths.get("").toAbsolutePath().toString();
    }

    /**
     * Gets the name of the current project.
     *
     * @return The name of the current project.
     */
    public String getProjectName(){
        return Paths.get("").toAbsolutePath().getFileName().toString();
    }

    /**
     * Zips the files in a directory and its subdirectories.
     *
     * @param zipDirName The name of the zip file.
     */
    public void zipDirectory(String zipDirName) {

        String root = this.getRootAbsPath();
        String zipFileNamePrefix = this.getProjectName();
        File dir = new File(root);
        String zipDirNameAndFileName = zipDirName + "/" + zipFileNamePrefix +".zip";



        try(FileOutputStream fos = new FileOutputStream(zipDirNameAndFileName);
            ZipOutputStream zos = new ZipOutputStream(fos)
            ) {
            populateFilesList(dir);
            for(String filePath : filesListInDir){
                System.out.println("Zipping "+filePath);
                ZipEntry ze = new ZipEntry(filePath.substring(dir.getAbsolutePath().length()+1, filePath.length()));
                zos.putNextEntry(ze);
                try (FileInputStream fis = new FileInputStream(filePath)) {
                    byte[] buffer = new byte[1024];
                    int len;
                    while ((len = fis.read(buffer)) > 0) {
                        zos.write(buffer, 0, len);
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Populates a list of files in a directory and its subdirectories.
     *
     * @param dir The directory to search for files.
     * @throws IOException If an error occurs while searching for files.
     */
    private void populateFilesList(File dir) throws IOException {
        File[] files = dir.listFiles();
        for(File file : Objects.requireNonNull(files)){
            if(file.isFile()) filesListInDir.add(file.getAbsolutePath());
            else populateFilesList(file);
        }
    }
}

