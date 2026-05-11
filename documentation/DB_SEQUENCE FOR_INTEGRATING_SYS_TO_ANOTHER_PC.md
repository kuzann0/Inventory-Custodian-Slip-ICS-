# IMPORTANT

# ONE BY ONE IF MULTIPLE CONTRAINTS

Constraint Format:
ADD CONSTRAINT FOREIGN KEY (`role_id`) REFERENCES `user_roles`(`id`) ON DELETE RESTRICT

--------------------------------------------------

1. User and User Roles

user's contraint:

ALTER TABLE users
 ADD CONSTRAINT FOREIGN KEY (`role_id`) REFERENCES `user_roles`(`id`) ON DELETE RESTRICT

2. Create role_id next

3.  Capabilities

Constraint: 
FOREIGN KEY (`required_role_id`) REFERENCES `user_roles`(`id`) ON DELETE SET NULL


4.  Purchase Requests

5. Admin Accounts 

Contraints:

  FOREIGN KEY (`admin_user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`created_by_superadmin_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT


6. Audit Logs

7. Role Audit Logs

8.  User Capabilities

9. Capability Audit Log

10. Approval Queue

11. OTP Codes

12. OTP Settings

13. Offline Emails (Optional)

14. Workflow History

15. Documents

16. Inspection Assignment

17. Entries

18. Proper Inventory

19. Login Audit

20. Admin Bypass Log

21. [ INSERT DEFAULT ROLES]

22. [ INSERT DEFAULT CAPABILITIES]

23. DEFAULT S.A. USER

24. S.A. USER CAPABILITIES

25. DEFAULT OTP SETTINGS

26. Commit
