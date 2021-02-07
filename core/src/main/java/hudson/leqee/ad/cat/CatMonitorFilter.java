package hudson.leqee.ad.cat;

import com.dianping.cat.Cat;
import com.dianping.cat.configuration.client.entity.ClientConfigProperty;
import com.dianping.cat.log.CatLogger;
import com.dianping.cat.servlet.CatFilter;
import com.leqee.boot.autoconfiguration.common.LogPathUtil;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.logging.Logger;

public class CatMonitorFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(CatMonitorFilter.class.getName());

    private static final String DEFAULT_SERVER = "10.0.16.134";

    private static final CatFilter CAT_FILTER = new CatFilter();

    private static final String REG = ".*(\\.png|\\.gif|\\.css|\\.js|\\.svg|\\.html|\\.xml|\\.woff)$";

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
        if (request instanceof HttpServletRequest) {
            HttpServletRequest httpServletRequest = (HttpServletRequest) request;
            final String path = httpServletRequest.getRequestURI();
            if (path.startsWith("/static/")
                    || path.startsWith("/sse-gateway/")
                    || path.startsWith("/$stapler/")
                    || path.matches(REG)) {
                LOGGER.info("path is no need to do CAT transaction:" + path);
                chain.doFilter(request, response);
                return;
            }
            CAT_FILTER.doFilter(request, response, chain);
        } else {
            chain.doFilter(request, response);
            return;
        }
    }

    @Override
    public void destroy() {

    }
}
