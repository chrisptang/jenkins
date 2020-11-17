package hudson.leqee.ad.cat;

import com.dianping.cat.Cat;
import com.dianping.cat.configuration.client.entity.ClientConfigProperty;
import com.dianping.cat.log.CatLogger;
import com.leqee.boot.autoconfiguration.common.LogPathUtil;

import javax.servlet.*;
import java.io.IOException;
import java.util.logging.Logger;

public class CatMonitorFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(CatMonitorFilter.class.getName());

    private static final String DEFAULT_SERVER = "10.0.16.134";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        //初始化CAT本地日志；
        CatLogger.updateLogHome(LogPathUtil.ensureLogPath("jenkins", "cat"));
        ClientConfigProperty property = new ClientConfigProperty();
        property.setAppId("jenkins");
        property.setPort(Integer.parseInt(System.getProperty("cat.port", "2280")));
        property.setHttpPort(Integer.parseInt(System.getProperty("cat.http.port", "30000")));

        property.setServers(new String[]{System.getProperty("cat.server", DEFAULT_SERVER)});
        Cat.initialize(property);

        LOGGER.info("CAT is initialized:" + Cat.isInitialized());
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {

    }
}
