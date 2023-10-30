# Start or Stop list of VMs use automation account
Hello folks,
Now we will learn how to implement automation for start or stop list of VMs in Azure using automation account
 Step for implement Start or Stop VMs automatically : 
 - Create Azure Automation Account
 - Grant RBAC like Virtual Machine Contributor to Automation Account
 - Create Runbook
 - Edit code in portal
 - Copy and paste code to text editor in portal
 - If you want to test the code, you can click test pane
 - Fill the parameter settings :
   - For VMName, you can fill one VM, or many VMs.
     - Example for one VM : 'vm1'
     - Example for many VMs : 'vm1','vm2','vm3'
   - Resource group
   - Subscription ID
   - Action : 'Start' for start VMs, and 'Stop' for stop VMs
 - Then, start the code
 - If testing success, then you can publish the runbook
 - You can also set schedule for the runbook
