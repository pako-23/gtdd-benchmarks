package tests;

import static org.junit.Assert.assertTrue;
import static utils.Login.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import po.ArchivedArticlesPage;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class SeeArchivedArticleTest {

	private WebDriver driver;

    @Before
	public void setUp() {
        driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testJoomlaSeeArchivedArticle() throws Exception {
		String title = "Test Article 00";
		ArchivedArticlesPage arts = loginAsAdmin(driver)
				.home()
				.testMenuItem();

		assertTrue(arts.containsArticle(title));
		arts.adminLogout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
