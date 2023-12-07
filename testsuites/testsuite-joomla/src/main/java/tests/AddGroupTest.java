package tests;


import static org.testng.AssertJUnit.assertEquals;
import static utils.Login.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import po.ManageGroupsPage;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;
import utils.DriverProvider;
import utils.Properties;

public class AddGroupTest {

	private WebDriver driver;

    @Before
	public void setUp() {
        driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testJoomlaAddGroup() throws Exception {
		String group = "Test Group 000";
		ManageGroupsPage groups = loginAsAdmin(driver)
			.siteAdmin()
			.setUsername("administrator")
			.setPassword("dodicicaratteri")
			.login()
			.sideUsers()
			.groups()
			.createGroup()
			.setTitle(group)
			.saveAndClose();

		assertEquals(group, groups.getIthGroupName(10));
		groups.logout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
