package tests;

import static org.junit.Assert.assertFalse;
import static utils.Login.*;
import po.ManageArticlesPage;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;
import utils.DriverProvider;
import utils.Properties;

public class DeleteArticleTest {

	private WebDriver driver;

	@Before

	public void setUp() {
		driver = DriverProvider.getInstance().getDriver();
		driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
		driver.get(Properties.app_url);
	}

	@Test
	public void testJoomlaDeleteArticle() throws Exception {
		String title = "Test Article 019";

		ManageArticlesPage articles = loginAsAdmin(driver)
				.siteAdmin()
				.setUsername("administrator")
				.setPassword("dodicicaratteri")
				.login()
				.articles()
				.showArchived()
				.deleteFirstArticle();

		assertFalse(articles.containsArticle(title));
		articles.logout();

	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
