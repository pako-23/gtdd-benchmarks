package tests;

import static org.junit.Assert.assertEquals;
import static utils.Login.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import po.ManageArticlesPage;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class ArchiveArticleTest {

	private WebDriver driver;

	@Before
	public void setUp() {
		driver = DriverProvider.getInstance().getDriver();
		driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
		driver.get(Properties.app_url);
	}

	@Test
	public void testJoomlaArchiveArticle() throws Exception {
		ManageArticlesPage articles = loginAsAdmin(driver)
				.siteAdmin()
				.setUsername("administrator")
				.setPassword("dodicicaratteri")
				.login()
				.articles()
				.archiveFirstArticle();

		assertEquals("Article archived.", articles.getAlertMessage());
		articles.logout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
