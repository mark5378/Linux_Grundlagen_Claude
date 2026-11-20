mkdir -p ablage/team ablage/austausch
chmod 750 ablage
chmod 2770 ablage/team
chmod 1770 ablage/austausch
touch ablage/team/plan.txt
chmod 660 ablage/team/plan.txt
printf '751\n2770\n1777\n4755\n' > umrechnung.txt
