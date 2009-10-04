#!/usr/bin/python

import sys
import datetime

FMT = 'y%Ym%md%d'

if len(sys.argv) != 4:
	print "partitions.py <year> <table> <column>"
	exit(1)

year = int(sys.argv[1])
table = sys.argv[2]
column = sys.argv[3]

if year < 2000 or year > 3000:
	print "expected year between 2000 and 3000"
	exit(1)

date = datetime.date(year,1,1)
date_last = datetime.date(year+1,1,1)
while date < date_last:
	date_1 = date + datetime.timedelta(days=1)
	print "CREATE TABLE %s_%s ( CHECK ( %s >= DATE '%s' AND %s < DATE '%s'  ) ) INHERITS (%s);" % \
		(table, date.strftime(FMT), column, date.strftime("%Y-%m-%d"), column, date_1.strftime("%Y-%m-%d"), table)
	print "CREATE INDEX %s_%s_%s ON %s_%s (%s);" % \
		(table,date.strftime(FMT),column,table,date.strftime(FMT),column)
	date = date_1

LEVEL = 1


class DateInterval:
	def __init__(self,start,end):
		self.start = start
		self.end = end
		if self.is_day():
			return
		half = int((end-start).days / 2)
		self.iv1 = DateInterval(start, start + datetime.timedelta(days=half))
		self.iv2 = DateInterval(start + datetime.timedelta(days=half+1), end)
		self.get_code = self.get_else
	def is_day(self):
		if (self.end-self.start).days == 0:
			return True
		else:
			return False
	def get_if(self):
		end = self.end + datetime.timedelta(days=1)
		if_text = "NEW.%s >= DATE '%s' AND NEW.%s < DATE '%s' THEN\n" % \
			(column, self.start.strftime("%Y-%m-%d"), column, end.strftime("%Y-%m-%d"))
		if_text += self.get_else()
		return if_text

	def get_else(self):
		global LEVEL
		if self.is_day():
			start2 = self.start + datetime.timedelta(days=-1)
			if self.start.year > start2.year:
				return self.get_out_of_year()
			else:
				return self.get_insert()
		LEVEL += 1
		l = LEVEL
		body = ' ' * l + 'IF ' + self.iv1.get_if()
		body += ' ' * l + 'ELSE\n' + self.iv2.get_else()
		body += ' ' * l + 'END IF;\n'
		LEVEL -= 1
		return body
	def get_insert(self):
		global LEVEL
		return ' ' * (LEVEL + 1) + 'INSERT INTO %s_%s VALUES (NEW.*);\n' % (table, self.start.strftime(FMT))
	def get_out_of_year(self):
		global LEVEL
		return ' ' * (LEVEL + 1) + "RAISE EXCEPTION 'Date out of range.  Fix the %s_insert_trigger() function!';\n" % table


	

date = datetime.date(year,1,1)
iv = DateInterval(date, date_last)

print 'CREATE OR REPLACE FUNCTION %s_insert_trigger()' % table
print 'RETURNS TRIGGER AS $$'
print 'BEGIN'
print iv.get_code()
print ' RETURN NULL;'
print 'END;'
print '$$ LANGUAGE plpgsql;'
print 'CREATE TRIGGER %s_trigger' % table
print 'BEFORE INSERT ON %s' % table
print 'FOR EACH ROW EXECUTE PROCEDURE %s_insert_trigger();' % table


