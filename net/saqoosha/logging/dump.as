package net.saqoosha.logging {
	import net.saqoosha.util.ObjectDumper;
	/**
	 * @author hiko
	 */
	public function dump(...args:*):void {
		if (args.length == 1) {
			ObjectDumper.dump(args[0]);
		} else {
			ObjectDumper.dump(args);
		}
	}
}
