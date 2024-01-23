package tests;

import static org.junit.Assert.assertEquals;
import static utils.Login.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import po.ManageArticlesPage;
import java.util.concurrent.TimeUnit;
import utils.DriverProvider;
import utils.Properties;
import org.openqa.selenium.WebDriver;

public class AssignCategoryTest {

	private WebDriver driver;

	@Before
	public void setUp() {
		driver = DriverProvider.getInstance().getDriver();
		driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
		driver.get(Properties.app_url);
	}

	@Test
	public void testJoomlaAssignCategory() throws Exception {

		String article = "Test Article 00";
		String cat = "Test Category 000";
		ManageArticlesPage articles = loginAsAdmin(driver)
				.siteAdmin()
				.setUsername("administrator")
				.setPassword("dodicicaratteri")
				.login()
				.articles()
				.goToArticle(article)
				.selectCategory(cat)
				.save();

		assertEquals(cat, articles.getIthArticleCategory(1));
		articles.logout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
