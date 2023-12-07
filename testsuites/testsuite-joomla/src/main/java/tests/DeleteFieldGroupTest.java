package tests;


import static org.junit.Assert.assertTrue;
import static utils.Login.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import po.ManageFieldGroupsPage;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class DeleteFieldGroupTest {

	private WebDriver driver;

    @Before
	public void setUp() {
        driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testJoomlaDeleteFieldGroup() throws Exception {
		String group = "Test Group 000";
		ManageFieldGroupsPage groups = loginAsAdmin(driver)
			.siteAdmin()
			.setUsername("administrator")
			.setPassword("dodicicaratteri")
			.login()
			.sideContent()
			.fieldGroups()
			.selectIthFieldGroup(1)
			.deleteSelectedGroup();

		assertTrue(!groups.isGroupPresentAtFirstRow(group));
		groups.logout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
