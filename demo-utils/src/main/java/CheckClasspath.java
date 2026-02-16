
public class CheckClasspath {
    public static void main(String[] args) {

        String[] cp=System.getProperty("java.class.path").split(System.getProperty("path.separator"));
        for(String s:cp) {
            int lr=s.indexOf("local-repo");
            if(lr>0) {
                String dep=s.substring(lr+11);
                int lastSlash=dep.lastIndexOf("/");
                if(lastSlash>0) {
                    dep=dep.substring(lastSlash+1);
                    System.out.println(dep);
                }

            }
        }

    }
}
